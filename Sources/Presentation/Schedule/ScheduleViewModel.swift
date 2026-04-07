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

        do {
            let festival = try await festivalsRepository.getLastFestival()
            let events = try await eventsRepository.getEvents(festivalID: festival.id)

            let zonesByID = await loadZones(for: events)
            let speakersByEventID = await loadSpeakersByEventID(for: events)

            entries = events.map { event in
                ScheduleEntry(
                    id: event.id,
                    event: event,
                    zone: zonesByID[event.zoneID],
                    speakers: speakersByEventID[event.id] ?? [],
                    streamURL: event.streamURL
                )
            }

            if #available(iOS 16.1, *) {
                await CurrentEventLiveActivityController.sync(with: entries)
            }
        } catch {
            entries = []
            loadError = error.localizedDescription
            if #available(iOS 16.1, *) {
                await CurrentEventLiveActivityController.sync(with: [])
            }
        }
    }

    /// Call when returning to foreground so the Live Activity tracks the session that is “now”.
    func syncCurrentEventLiveActivity() async {
        if #available(iOS 16.1, *) {
            await CurrentEventLiveActivityController.sync(with: entries)
        }
    }

    private func loadZones(for events: [Event]) async -> [String: Zone] {
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

    private func loadSpeakersByEventID(for events: [Event]) async -> [String: [Speaker]] {
        let eventIDs = Set(events.map(\.id))
        var speakersByEventID: [String: [Speaker]] = [:]

        guard let speakers = try? await speakersRepository.getAllSpeakers() else {
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
}
