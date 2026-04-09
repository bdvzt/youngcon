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

    private var pollingTask: Task<Void, Never>?

    private(set) var entries: [ScheduleEntry] = []
    private(set) var favoriteEventIDs: Set<String> = []
    private(set) var isLoading = false
    private(set) var loadError: String?

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

    func load() async {
        await load(policy: .cacheFirst, shouldReplaceOnlyIfChanged: true)
    }

    func refreshFromNetworkIfNeeded() async {
        await load(policy: .networkFirst, shouldReplaceOnlyIfChanged: true)
    }

    func startPolling(every seconds: TimeInterval = 60) {
        stopPolling()

        pollingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                await refreshFromNetworkIfNeeded()

                do {
                    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                } catch {
                    break
                }
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    /// Call when returning to foreground so the Live Activity tracks the session that is “now”.
    func syncCurrentEventLiveActivity() async {
        if #available(iOS 16.1, *) {
            await CurrentEventLiveActivityController.sync(with: entries)
        }
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

    private func load(
        policy: CachePolicy,
        shouldReplaceOnlyIfChanged: Bool
    ) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let newState = try await buildScheduleState(policy: policy)

            let entriesChanged = newState.entries != entries
            let favoritesChanged = newState.favoriteEventIDs != favoriteEventIDs

            if !shouldReplaceOnlyIfChanged || entriesChanged {
                entries = newState.entries

                if #available(iOS 16.1, *) {
                    await CurrentEventLiveActivityController.sync(with: entries)
                }
            }

            if !shouldReplaceOnlyIfChanged || favoritesChanged {
                favoriteEventIDs = newState.favoriteEventIDs
            }

            loadError = nil
        } catch {
            loadError = error.localizedDescription

            if entries.isEmpty, #available(iOS 16.1, *) {
                await CurrentEventLiveActivityController.sync(with: [])
            }
        }
    }

    private func buildScheduleState(policy: CachePolicy) async throws -> ScheduleState {
        let festival = try await festivalsRepository.getLastFestival(policy: policy)
        let events = try await eventsRepository.getEvents(
            festivalID: festival.id,
            policy: policy
        )

        async let favoriteIDsTask = loadFavoriteEventIDs(policy: policy)
        async let zonesByIDTask = loadZones(for: events, policy: policy)
        async let speakersByEventIDTask = loadSpeakersByEventID(for: events, policy: policy)

        let zonesByID = await zonesByIDTask
        let speakersByEventID = await speakersByEventIDTask
        let favoriteIDs = await favoriteIDsTask

        let newEntries = events.map { event in
            ScheduleEntry(
                id: event.id,
                event: event,
                zone: zonesByID[event.zoneID],
                speakers: speakersByEventID[event.id] ?? [],
                streamURL: event.streamURL
            )
        }

        return ScheduleState(
            entries: newEntries,
            favoriteEventIDs: favoriteIDs
        )
    }

    private func loadZones(
        for events: [Event],
        policy: CachePolicy
    ) async -> [String: Zone] {
        let zoneIDs = Set(events.map(\.zoneID).filter { !$0.isEmpty })
        var zonesByID: [String: Zone] = [:]

        await withTaskGroup(of: (String, Zone?).self) { group in
            for zoneID in zoneIDs {
                group.addTask { [zoneRepository] in
                    let zone = try? await zoneRepository.getZone(
                        zoneID: zoneID,
                        policy: policy
                    )
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

    private func loadSpeakersByEventID(
        for events: [Event],
        policy: CachePolicy
    ) async -> [String: [Speaker]] {
        let eventIDs = Set(events.map(\.id))
        var speakersByEventID: [String: [Speaker]] = [:]

        guard let speakers = try? await speakersRepository.getAllSpeakers(policy: policy) else {
            return speakersByEventID
        }

        await withTaskGroup(of: [(String, Speaker)].self) { group in
            for speaker in speakers {
                group.addTask { [eventsRepository] in
                    guard let speakerEvents = try? await eventsRepository.getSpeakerEvents(speakerID: speaker.id)
                    else { return [] }

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

    private func loadFavoriteEventIDs(policy: CachePolicy) async -> Set<String> {
        guard let profile = try? await usersRepository.getMyProfile(policy: policy),
              let likedEvents = try? await usersRepository.getUserLikedEvents(
                  userID: profile.id,
                  policy: policy
              )
        else {
            return []
        }
        return Set(likedEvents.map(\.id))
    }
}

private struct ScheduleState: Equatable {
    let entries: [ScheduleEntry]
    let favoriteEventIDs: Set<String>
}
