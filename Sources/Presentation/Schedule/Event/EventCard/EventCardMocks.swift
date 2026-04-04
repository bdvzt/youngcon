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
            bio: "Иван работает в Яндексе более 5 лет. Руководит разработкой мобильного приложения Яндекс.Карт. Спикер конференций Mobius и RIW.",
            avatarURL: "https://example.com/photos/ivan-petrov.jpg"
        ),
        Speaker(
            id: "speaker-mock-002",
            fullName: "Мария Соколова",
            job: "Staff Engineer, Mobile Platform",
            bio: "Архитектура и производительность больших iOS-клиентов. Ранее — лид мобильной разработки в e-commerce.",
            avatarURL: "https://example.com/photos/maria-sokolova.jpg"
        ),
    ]

    /// Событие «в эфире» — start раньше текущего времени, end позже.
    static var event: Event {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        let start = Date().addingTimeInterval(-30 * 60)
        let end   = Date().addingTimeInterval(2 * 60 * 60)
        return Event(
            id: "event-mock-001",
            title: "Разработка на Swift: современные подходы и best practices",
            description: "Глубокое погружение в современный Swift. Concurrency, SwiftUI, архитектура.",
            startDateTime: fmt.string(from: start),
            endDateTime: fmt.string(from: end),
            category: "development",
            zoneID: "zone-mock-001",
            festivalID: "youngcon-2026"
        )
    }

    /// Короткий доклад без зоны и трансляции.
    static var shortEvent: Event {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        let start = Date().addingTimeInterval(60 * 60)
        let end   = Date().addingTimeInterval(2 * 60 * 60)
        return Event(
            id: "event-mock-002",
            title: "Короткий доклад",
            description: "Краткое выступление без трансляции.",
            startDateTime: fmt.string(from: start),
            endDateTime: fmt.string(from: end),
            category: "talk",
            zoneID: "",
            festivalID: "youngcon-2026"
        )
    }
}
