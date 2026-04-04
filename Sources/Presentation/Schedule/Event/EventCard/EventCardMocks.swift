import Foundation

// MARK: - Mocks (данные для карточки события)

enum EventCardMocks {
    enum IDs {
        static let event = "11111111-1111-1111-1111-111111111111"
        static let zone = "22222222-2222-2222-2222-222222222222"
        static let speaker1 = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
        static let speaker2 = "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
        static let festival = "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"
        static let floor = "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD"
    }

    static let zone = Zone(
        id: IDs.zone,
        floorID: IDs.floor,
        title: "Главная сцена",
        description: "",
        icon: "theatermasks.fill",
        color: "indigo"
    )

    static let speakers: [Speaker] = [
        Speaker(
            id: IDs.speaker1,
            fullName: "Иван Петров",
            job: "Lead iOS Developer",
            bio: """
            Иван работает в Яндексе более 5 лет. Руководит разработкой мобильного приложения Яндекс.Карт.
            Спикер конференций Mobius и RIW. Увлекается SwiftUI и анимациями.
            """,
            avatarURL: "https://example.com/photos/ivan-petrov.jpg"
        ),
        Speaker(
            id: IDs.speaker2,
            fullName: "Мария Соколова",
            job: "Staff Engineer, Mobile Platform",
            bio: """
            Архитектура и производительность больших iOS-клиентов. Ранее — лид мобильной разработки в e-commerce.
            """,
            avatarURL: "https://example.com/photos/maria-sokolova.jpg"
        ),
    ]

    /// Интервал относительно «сейчас», чтобы в превью всегда были live-точка.
    static var event: Event {
        let formatter = ISO8601DateFormatter()
        let now = Date()
        let start = now.addingTimeInterval(-30 * 60)
        let end = now.addingTimeInterval(2 * 60 * 60)
        return Event(
            id: IDs.event,
            title: "Разработка на Swift: современные подходы и best practices",
            description: "Превью карточки события.",
            startDateTime: formatter.string(from: start),
            endDateTime: formatter.string(from: end),
            category: "development",
            zoneID: IDs.zone,
            festivalID: IDs.festival
        )
    }
}
