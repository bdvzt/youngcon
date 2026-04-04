import Foundation

// MARK: - Mocks (данные для карточки события)

enum EventCardMocks {
    enum IDs {
        static let event = Self.uuid("11111111-1111-1111-1111-111111111111")
        static let zone = Self.uuid("22222222-2222-2222-2222-222222222222")
        static let speaker1 = Self.uuid("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
        static let speaker2 = Self.uuid("BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")

        private static func uuid(_ string: String) -> UUID {
            guard let id = UUID(uuidString: string) else {
                preconditionFailure("Invalid mock UUID string: \(string)")
            }
            return id
        }
    }

    static let zone = Zone(
        id: IDs.zone,
        name: "Главная сцена",
        iconName: "theatermasks.fill",
        color: "indigo"
    )

    static let speakers: [Speaker] = [
        Speaker(
            id: IDs.speaker1,
            name: "Иван Петров",
            role: "Lead iOS Developer",
            bio: """
            Иван работает в Яндексе более 5 лет. Руководит разработкой мобильного приложения Яндекс.Карт.
            Спикер конференций Mobius и RIW. Увлекается SwiftUI и анимациями.
            """,
            photoURL: URL(string: "https://example.com/photos/ivan-petrov.jpg")
        ),
        Speaker(
            id: IDs.speaker2,
            name: "Мария Соколова",
            role: "Staff Engineer, Mobile Platform",
            bio: """
            Архитектура и производительность больших iOS-клиентов. Ранее — лид мобильной разработки в e-commerce.
            """,
            photoURL: URL(string: "https://example.com/photos/maria-sokolova.jpg")
        ),
    ]

    /// Интервал относительно «сейчас», чтобы в превью всегда были live-точка и кнопка трансляции.
    static var event: Event {
        let now = Date()
        return Event(
            id: IDs.event,
            title: "Разработка на Swift: современные подходы и best practices",
            start: now.addingTimeInterval(-30 * 60),
            end: now.addingTimeInterval(2 * 60 * 60),
            speakerIDs: [IDs.speaker1, IDs.speaker2],
            zoneID: IDs.zone,
            categoryCode: "development",
            streamURL: URL(string: "https://example.com/stream/2026/swift-talk")
        )
    }
}
