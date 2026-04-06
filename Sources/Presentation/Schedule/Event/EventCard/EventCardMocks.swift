import Foundation

enum EventCardMocks {
    static let zone = Zone(
        id: "zone-mock-001",
        floorID: "floor-1",
        title: "Главная сцена",
        description: "Основная сцена фестиваля",
        icon: "theatermasks.fill",
        color: "indigo"
    )

    static let speakers: [Speaker] = [
        Speaker(
            id: "speaker-mock-001",
            fullName: "Иван Петров",
            job: "Lead iOS Developer",
            bio: "Иван работает в Яндексе более 5 лет.",
            avatarURL: "https://example.com/photos/ivan-petrov.jpg"
        ),
        Speaker(
            id: "speaker-mock-002",
            fullName: "Мария Соколова",
            job: "Staff Engineer, Mobile Platform",
            bio: "Архитектура и производительность больших iOS-клиентов.",
            avatarURL: "https://example.com/photos/maria-sokolova.jpg"
        ),
    ]

    static var liveEvent: Event {
        let start = Date().addingTimeInterval(-30 * 60)
        let end = Date().addingTimeInterval(90 * 60)
        return Event(
            id: "event-001",
            title: "Открытие YoungCon: Будущее бигтеха",
            description: "Ежегодное открытие фестиваля.",
            startDateTime: EventDateParser.string(from: start),
            endDateTime: EventDateParser.string(from: end),
            category: "talk",
            zoneID: "zone-mock-001",
            festivalID: "youngcon-2026"
        )
    }

    static var upcomingEvent: Event {
        let start = Date().addingTimeInterval(60 * 60)
        let end = Date().addingTimeInterval(2 * 60 * 60)
        return Event(
            id: "event-002",
            title: "Как мы переписали бэкенд на Go и выжили",
            description: "Реальный кейс перехода с монолита на микросервисы.",
            startDateTime: EventDateParser.string(from: start),
            endDateTime: EventDateParser.string(from: end),
            category: "development",
            zoneID: "",
            festivalID: "youngcon-2026"
        )
    }
}
