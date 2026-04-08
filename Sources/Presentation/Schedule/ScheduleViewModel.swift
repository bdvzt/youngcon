import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    private let festivalsRepository: FestivalsRepositoryProtocol
    private let eventsRepository: EventsRepositoryProtocol
    private let zoneRepository: ZoneRepositoryProtocol
    private let speakersRepository: SpeakersRepositoryProtocol

    private(set) var entries: [ScheduleEntry] = []
    private(set) var isLoading = false
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

    private var isRefreshing = false
    private var pollingTask: Task<Void, Never>?

    init(
        festivalsRepository: FestivalsRepositoryProtocol,
        eventsRepository: EventsRepositoryProtocol,
        zoneRepository: ZoneRepositoryProtocol,
        speakersRepository: SpeakersRepositoryProtocol
    ) {
        self.festivalsRepository = festivalsRepository
        self.eventsRepository = eventsRepository
        self.zoneRepository = zoneRepository
        self.speakersRepository = speakersRepository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        await fetchAll(isFirstLoad: true)
    }

    func refresh() async {
        await fetchAll(isFirstLoad: false)
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

    private func fetchAll(isFirstLoad: Bool) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        if isFirstLoad {
            loadError = nil
        }

        do {
            let newEntries = try await loadScheduleEntries()

            guard shouldApplyChanges(
                isFirstLoad: isFirstLoad,
                newEntries: newEntries
            ) else {
                return
            }

            entries = newEntries
        } catch {
            if isFirstLoad {
                entries = []
                loadError = error.localizedDescription
            } else {
                print("[Schedule] Polling error: \(error.localizedDescription)")
            }
        }
    }
}

private extension ScheduleViewModel {
    func shouldApplyChanges(
        isFirstLoad: Bool,
        newEntries: [ScheduleEntry]
    ) -> Bool {
        if isFirstLoad {
            return true
        }
        return entries != newEntries
    }

    func loadScheduleEntries() async throws -> [ScheduleEntry] {
        let festival = try await festivalsRepository.getLastFestival()
        let events = try await eventsRepository.getEvents(festivalID: festival.id)

        async let zonesTask = loadZones(for: events)
        async let speakersTask = loadSpeakersByEventID(for: events)

        let zonesByID = await zonesTask
        let speakersByEventID = await speakersTask

        return events.map { event in
            ScheduleEntry(
                id: event.id,
                event: event,
                zone: zonesByID[event.zoneID],
                speakers: speakersByEventID[event.id] ?? [],
                streamURL: event.streamURL
            )
        }
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
}
