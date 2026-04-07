import Foundation
import SwiftUI

// MARK: - Preview errors

enum PreviewRepositoryError: Error {
    case notFound
}

// MARK: - Schedule preview store & fixtures

/// Shared in-memory state for preview schedule repositories.
final class SchedulePreviewStore {
    let festival: Festival
    let events: [Event]
    private let zonesByID: [String: Zone]
    let speakers: [Speaker]
    private let speakerToEventIDs: [String: [String]]

    init(
        festival: Festival,
        events: [Event],
        zonesByID: [String: Zone],
        speakers: [Speaker],
        speakerToEventIDs: [String: [String]]
    ) {
        self.festival = festival
        self.events = events
        self.zonesByID = zonesByID
        self.speakers = speakers
        self.speakerToEventIDs = speakerToEventIDs
    }

    func zone(forZoneID zoneID: String) -> Zone? {
        zonesByID[zoneID]
    }

    func anyZone() -> Zone? {
        zonesByID.values.first
    }

    func speakerEvents(speakerID: String) -> [Event] {
        let ids = Set(speakerToEventIDs[speakerID] ?? [])
        return events.filter { ids.contains($0.id) }
    }
}

/// Factory for preview-only schedule domain data (not production fixtures).
enum SchedulePreviewFixtures {
    private static let festivalID = "preview-festival"
    private static let zoneID = "preview-zone-main"

    static func makeStore(referenceDate: Date = .now) -> SchedulePreviewStore {
        let festival = Festival(
            id: festivalID,
            title: "YoungCon — превью",
            description: "Локальные данные для SwiftUI Preview",
            startDate: referenceDate.addingTimeInterval(-86400),
            endDate: referenceDate.addingTimeInterval(86400)
        )

        let liveStart = referenceDate.addingTimeInterval(-5 * 60)
        let liveEnd = referenceDate.addingTimeInterval(30 * 60)

        let liveEvent = Event(
            id: "event-001",
            title: "Сейчас в эфире (превью)",
            description: "Мок события для проверки Live и карточки",
            startDate: liveStart,
            endDate: liveEnd,
            category: "Лекция",
            zoneID: zoneID,
            festivalID: festivalID,
            streamURL: URL(string: "https://example.com/live-preview")
        )

        let upcomingEvent = Event(
            id: "event-upcoming",
            title: "Следующая лекция",
            description: "Начнётся позже",
            startDate: referenceDate.addingTimeInterval(3600),
            endDate: referenceDate.addingTimeInterval(10800),
            category: "Backend",
            zoneID: zoneID,
            festivalID: festivalID,
            streamURL: nil
        )

        let zone = Zone(
            id: zoneID,
            floorID: "preview-floor-1",
            title: "Главный зал",
            description: "Превью зона",
            cordX: 0.5,
            cordY: 0.5,
            icon: URL(string: "https://picsum.photos/seed/youngcon-zone/64")!,
            color: AppColor.accentPurple
        )

        let speaker = Speaker(
            id: "preview-speaker-1",
            fullName: "Анна Превью",
            job: "iOS-разработчик",
            bio: "Тестовый спикер для превью",
            avatarImageURL: URL(string: "https://picsum.photos/seed/youngcon-speaker/96")
        )

        let events = [liveEvent, upcomingEvent]
        let zonesByID = [zoneID: zone]
        let speakers = [speaker]
        let speakerToEventIDs = [speaker.id: [liveEvent.id]]

        return SchedulePreviewStore(
            festival: festival,
            events: events,
            zonesByID: zonesByID,
            speakers: speakers,
            speakerToEventIDs: speakerToEventIDs
        )
    }
}

// MARK: - Schedule preview repositories

final class PreviewFestivalsRepository: FestivalsRepositoryProtocol {
    private let store: SchedulePreviewStore

    init(store: SchedulePreviewStore) {
        self.store = store
    }

    func getLastFestival() async throws -> Festival {
        store.festival
    }
}

final class PreviewEventsRepository: EventsRepositoryProtocol {
    private let store: SchedulePreviewStore

    init(store: SchedulePreviewStore) {
        self.store = store
    }

    func getEvents(festivalID: String) async throws -> [Event] {
        store.events.filter { $0.festivalID == festivalID }
    }

    func getEvent(eventID: String) async throws -> Event {
        guard let event = store.events.first(where: { $0.id == eventID }) else {
            throw PreviewRepositoryError.notFound
        }
        return event
    }

    func getZoneEvents(zoneID: String) async throws -> [Event] {
        store.events.filter { $0.zoneID == zoneID }
    }

    func getSpeakerEvents(speakerID: String) async throws -> [Event] {
        store.speakerEvents(speakerID: speakerID)
    }

    func likeEvent(eventID: String) async throws -> LikeEventResponse {
        LikeEventResponse(eventID: eventID, userID: "preview-user", isLiked: true)
    }
}

final class PreviewZoneRepository: ZoneRepositoryProtocol {
    private let store: SchedulePreviewStore

    init(store: SchedulePreviewStore) {
        self.store = store
    }

    func getZone(zoneID: String) async throws -> Zone {
        guard let zone = store.zone(forZoneID: zoneID) else {
            throw PreviewRepositoryError.notFound
        }
        return zone
    }

    func getZone(floorID _: String) async throws -> Zone {
        guard let zone = store.anyZone() else {
            throw PreviewRepositoryError.notFound
        }
        return zone
    }
}

final class PreviewSpeakersRepository: SpeakersRepositoryProtocol {
    private let store: SchedulePreviewStore

    init(store: SchedulePreviewStore) {
        self.store = store
    }

    func getSpeaker(speakerID: String) async throws -> Speaker {
        guard let speaker = store.speakers.first(where: { $0.id == speakerID }) else {
            throw PreviewRepositoryError.notFound
        }
        return speaker
    }

    func getAllSpeakers() async throws -> [Speaker] {
        store.speakers
    }
}

// MARK: - Other tabs (preview stubs)

final class PreviewAuthRepository: AuthRepositoryProtocol {
    func login(email _: String, password _: String) async throws {}

    func logout() async throws {}
}

final class PreviewAchievementsRepository: AchievementsRepositoryProtocol {
    func getAchievements() async throws -> [Achievement] {
        []
    }
}

final class PreviewFloorsRepository: FloorsRepositoryProtocol {
    func getFloor(id: String) async throws -> Floor {
        Floor(
            id: id,
            title: "Превью этаж",
            mapImageURL: URL(string: "https://picsum.photos/seed/youngcon-floor/400/300")!
        )
    }

    func getFloors() async throws -> [Floor] {
        let floor = try await getFloor(id: "preview-floor-1")
        return [floor]
    }
}

final class PreviewUsersRepository: UsersRepositoryProtocol {
    func getMyProfile() async throws -> UserProfile {
        UserProfile(
            id: "preview-user",
            firstName: "Превью",
            lastName: "Пользователь",
            email: "preview@example.com",
            qrCode: "preview-qr",
            major: .mobile,
            role: .client
        )
    }

    func getUserLikedEvents(userID _: String) async throws -> [Event] {
        []
    }

    func getUserAchievements(userID _: String) async throws -> [Achievement] {
        []
    }
}
