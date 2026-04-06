import Foundation
import Observation
import OSLog

private let scheduleLogger = Logger(subsystem: "com.bdvzt.YoungCon", category: "Schedule")

@MainActor
@Observable
final class ScheduleViewModel {
    private let festivalsRepository: FestivalsRepositoryProtocol
    private let eventsRepository: EventsRepositoryProtocol
    private let zoneRepository: ZoneRepositoryProtocol

    private(set) var festival: Festival?
    private(set) var entries: [ScheduleEntry] = []
    private(set) var isLoading = false
    private(set) var loadError: ScheduleError?

    init(
        festivalsRepository: FestivalsRepositoryProtocol,
        eventsRepository: EventsRepositoryProtocol,
        zoneRepository: ZoneRepositoryProtocol
    ) {
        self.festivalsRepository = festivalsRepository
        self.eventsRepository = eventsRepository
        self.zoneRepository = zoneRepository
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let festival = try await festivalsRepository.getLastFestival()
            self.festival = festival

            let events = try await eventsRepository.getEvents(festivalID: festival.id)
            let zonesByID = await loadZones(for: events)
            let speakersByEventID = await loadSpeakers(for: events)

            entries = events.map { event in
                let zone = event.zoneID.isEmpty ? nil : zonesByID[event.zoneID]
                let speakers = speakersByEventID[event.id] ?? []
                return ScheduleEntry(
                    id: event.id,
                    event: event,
                    zone: zone,
                    speakers: speakers,
                    streamURL: nil
                )
            }
        } catch {
            loadError = ScheduleError(error)
            entries = []
            festival = nil
        }
    }

    private func loadZones(for events: [Event]) async -> [String: Zone] {
        let ids = Set(events.map(\.zoneID).filter { !$0.isEmpty })
        var zonesByID: [String: Zone] = [:]
        await withTaskGroup(of: (String, Zone?).self) { group in
            for id in ids {
                group.addTask { [zoneRepository] in
                    let zone = try? await zoneRepository.getZone(zoneID: id)
                    return (id, zone)
                }
            }
            for await (id, zone) in group {
                if let zone {
                    zonesByID[id] = zone
                } else {
                    scheduleLogger.warning("Не удалось загрузить зону id=\(id, privacy: .public)")
                }
            }
        }
        return zonesByID
    }

    private func loadSpeakers(for events: [Event]) async -> [String: [Speaker]] {
        var map: [String: [Speaker]] = [:]
        await withTaskGroup(of: (String, [Speaker]).self) { group in
            for event in events {
                group.addTask { [eventsRepository] in
                    do {
                        let speakers = try await eventsRepository.getEventSpeakers(eventID: event.id)
                        return (event.id, speakers)
                    } catch {
                        // swiftlint:disable:next line_length
                        scheduleLogger.warning("Не удалось загрузить спикеров события id=\(event.id, privacy: .public): \(error.localizedDescription, privacy: .public)")
                        return (event.id, [])
                    }
                }
            }
            for await (eventID, speakers) in group {
                map[eventID] = speakers
            }
        }
        return map
    }
}
