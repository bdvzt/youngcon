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
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let festival = try await festivalsRepository.getLastFestival()
            let events = try await eventsRepository.getEvents(festivalID: festival.id)

            async let favoriteIDs = loadFavoriteEventIDs()
            let zonesByID = await loadZones(for: events)
            let speakersByEventID = await loadSpeakersByEventID(for: events)
            favoriteEventIDs = await favoriteIDs

            entries = events.map { event in
                ScheduleEntry(
                    id: event.id,
                    event: event,
                    zone: zonesByID[event.zoneID],
                    speakers: speakersByEventID[event.id] ?? [],
                    streamURL: event.streamURL
                )
            }
        } catch {
            loadError = error.localizedDescription
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

    private func loadFavoriteEventIDs() async -> Set<String> {
        guard let profile = try? await usersRepository.getMyProfile(),
              let likedEvents = try? await usersRepository.getUserLikedEvents(userID: profile.id)
        else {
            return []
        }
        return Set(likedEvents.map(\.id))
    }
}
