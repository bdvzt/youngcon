import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    private let festivalsRepository: FestivalsRepositoryProtocol
    private let eventsRepository: EventsRepositoryProtocol
    private let zoneRepository: ZoneRepositoryProtocol
    private let speakersRepository: SpeakersRepositoryProtocol
    private let usersRepository: UsersRepositoryProtocol

    private(set) var entries: [ScheduleEntry] = []
    private(set) var favoriteEventIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var isRefreshingUI = false
    private(set) var loadError: String?

    var filters: [String] {
        let categories = Set(
            entries.map {
                $0.event.category
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .capitalized
            }
        )
        return ["Все", "Live", "Избранное"] + categories.sorted()
    }

    private var pollingTask: Task<Void, Never>?

    init(
        festivalsRepository: FestivalsRepositoryProtocol,
        eventsRepository: EventsRepositoryProtocol,
        zoneRepository: ZoneRepositoryProtocol,
        speakersRepository: SpeakersRepositoryProtocol,
        usersRepository: UsersRepositoryProtocol
    ) {
        self.festivalsRepository = festivalsRepository
        self.eventsRepository = eventsRepository
        self.zoneRepository = zoneRepository
        self.speakersRepository = speakersRepository
        self.usersRepository = usersRepository
    }

    // MARK: - Public API

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        await fetchAll(isFirstLoad: true)
    }

    func startPolling() {
        guard pollingTask == nil else { return }

        pollingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                await fetchAll(isFirstLoad: false)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func isFavorite(eventID: String) -> Bool {
        favoriteEventIDs.contains(eventID)
    }

    func toggleFavorite(eventID: String) async -> Bool {
        do {
            let response = try await eventsRepository.likeEvent(eventID: eventID)

            if response.isLiked {
                favoriteEventIDs.insert(eventID)
            } else {
                favoriteEventIDs.remove(eventID)
            }

            return response.isLiked
        } catch {
            return favoriteEventIDs.contains(eventID)
        }
    }

    // MARK: - Core logic

    private func fetchAll(isFirstLoad: Bool) async {
        if isFirstLoad {
            loadError = nil
        }

        do {
            let payload = try await loadSchedulePayload()

            guard shouldApplyChanges(
                isFirstLoad: isFirstLoad,
                newEntries: payload.entries,
                newFavoriteEventIDs: payload.favoriteEventIDs
            ) else {
                return
            }

            entries = payload.entries
            favoriteEventIDs = payload.favoriteEventIDs
        } catch {
            if isFirstLoad {
                entries = []
                favoriteEventIDs = []
                loadError = error.localizedDescription
            } else {
                print("[Schedule] Polling error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Private helpers

private extension ScheduleViewModel {
    struct SchedulePayload {
        let entries: [ScheduleEntry]
        let favoriteEventIDs: Set<String>
    }

    func shouldApplyChanges(
        isFirstLoad: Bool,
        newEntries: [ScheduleEntry],
        newFavoriteEventIDs: Set<String>
    ) -> Bool {
        if isFirstLoad {
            return true
        }

        let entriesChanged = entries != newEntries
        let favoritesChanged = favoriteEventIDs != newFavoriteEventIDs

        return entriesChanged || favoritesChanged
    }

    func loadSchedulePayload() async throws -> SchedulePayload {
        let festival = try await festivalsRepository.getLastFestival()
        let events = try await eventsRepository.getEvents(festivalID: festival.id)

        async let zonesTask = loadZones(for: events)
        async let speakersTask = loadSpeakersByEventID(for: events)
        async let favoriteIDsTask = loadFavoriteEventIDs()

        let zonesByID = await zonesTask
        let speakersByEventID = await speakersTask
        let favoriteIDs = await favoriteIDsTask

        let entries = events.map { event in
            ScheduleEntry(
                id: event.id,
                event: event,
                zone: zonesByID[event.zoneID],
                speakers: speakersByEventID[event.id] ?? [],
                streamURL: event.streamURL
            )
        }

        return SchedulePayload(
            entries: entries,
            favoriteEventIDs: favoriteIDs
        )
    }

    func loadZones(for events: [Event]) async -> [String: Zone] {
        let zoneIDs = Set(events.map(\.zoneID).filter { !$0.isEmpty })
        var zonesByID: [String: Zone] = [:]

        await withTaskGroup(of: (String, Zone?).self) { group in
            for zoneID in zoneIDs {
                group.addTask { [zoneRepository] in
                    let zone = try? await zoneRepository.getZone(zoneID: zoneID)
                    return (zoneID, zone)
                }
            }

            for await (zoneID, zone) in group {
                if let zone {
                    zonesByID[zoneID] = zone
                }
            }
        }

        return zonesByID
    }

    func loadSpeakersByEventID(for events: [Event]) async -> [String: [Speaker]] {
        let eventIDs = Set(events.map(\.id))
        var speakersByEventID: [String: [Speaker]] = [:]

        guard let speakers = try? await speakersRepository.getAllSpeakers() else {
            return speakersByEventID
        }

        await withTaskGroup(of: [(String, Speaker)].self) { group in
            for speaker in speakers {
                group.addTask { [eventsRepository] in
                    guard let speakerEvents = try? await eventsRepository.getSpeakerEvents(
                        speakerID: speaker.id
                    ) else {
                        return []
                    }

                    return speakerEvents
                        .filter { eventIDs.contains($0.id) }
                        .map { ($0.id, speaker) }
                }
            }

            for await pairs in group {
                for (eventID, speaker) in pairs {
                    var list = speakersByEventID[eventID] ?? []
                    if !list.contains(where: { $0.id == speaker.id }) {
                        list.append(speaker)
                    }
                    speakersByEventID[eventID] = list
                }
            }
        }

        return speakersByEventID
    }

    func loadFavoriteEventIDs() async -> Set<String> {
        guard let profile = try? await usersRepository.getMyProfile(),
              let likedEvents = try? await usersRepository.getUserLikedEvents(userID: profile.id)
        else {
            return []
        }

        return Set(likedEvents.map(\.id))
    }
}
