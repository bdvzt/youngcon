import Foundation
import SwiftUI

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
        description: "Основная сцена фестиваля",
        cordX: nil,
        cordY: nil,
        icon: URL(string: "https://example.com/icon.png")!,
        color: .indigo
    )

    static let speakers: [Speaker] = [
        Speaker(
            id: IDs.speaker1,
            fullName: "Иван Петров",
            job: "Lead iOS Developer",
            bio: "Иван работает в Яндексе более 5 лет.",
            avatarImageURL: URL(string: "https://example.com/photos/ivan-petrov.jpg")
        ),
        Speaker(
            id: IDs.speaker2,
            fullName: "Мария Соколова",
            job: "Staff Engineer, Mobile Platform",
            bio: "Архитектура и производительность больших iOS-клиентов.",
            avatarImageURL: URL(string: "https://example.com/photos/maria-sokolova.jpg")
        ),
    ]

    static var liveEvent: Event {
        let start = Date().addingTimeInterval(-30 * 60)
        let end = Date().addingTimeInterval(90 * 60)
        return Event(
            id: "event-001",
            title: "Открытие YoungCon: Будущее бигтеха",
            description: "Ежегодное открытие фестиваля.",
            startDate: start,
            endDate: end,
            category: "talk",
            zoneID: "zone-mock-001",
            festivalID: "youngcon-2026",
            streamURL: nil
        )
    }

    static var upcomingEvent: Event {
        let start = Date().addingTimeInterval(60 * 60)
        let end = Date().addingTimeInterval(2 * 60 * 60)
        return Event(
            id: "event-002",
            title: "Как мы переписали бэкенд на Go и выжили",
            description: "Реальный кейс перехода с монолита на микросервисы.",
            startDate: start,
            endDate: end,
            category: "development",
            zoneID: "",
            festivalID: IDs.festival,
            streamURL: nil
        )
    }
}
