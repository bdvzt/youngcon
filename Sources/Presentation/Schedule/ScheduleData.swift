import Foundation
import SwiftUI

// MARK: - Date Helpers

private func dateToday(hour: Int, minute: Int) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute
    components.second = 0
    return Calendar.current.date(from: components) ?? Date()
}

// MARK: - Schedule Data (Mock Events)

let scheduleData: [Event] = [
    Event(
        id: "event-001",
        title: "Открытие YoungCon: Будущее бигтеха",
        description: "Ежегодное открытие фестиваля. Поговорим о том, куда движутся технологии.",
        startDate: dateToday(hour: 10, minute: 0),
        endDate: dateToday(hour: 12, minute: 0),
        category: "лекция",
        zoneID: "zone-001",
        festivalID: "youngcon-2026",
        streamURL: URL(string: "https://stream.example.com/event-001")
    ),

    Event(
        id: "event-002",
        title: "Как мы переписали бэкенд на Go и выжили",
        description: "Реальный кейс перехода с монолита на микросервисы.",
        startDate: dateToday(hour: 12, minute: 30),
        endDate: dateToday(hour: 14, minute: 0),
        category: "backend",
        zoneID: "zone-002",
        festivalID: "youngcon-2026",
        streamURL: URL(string: "https://stream.example.com/event-002")
    ),

    Event(
        id: "event-003",
        title: "Дизайн-ревью: Приноси свои макеты",
        description: "Разбираем работы участников в прямом эфире.",
        startDate: dateToday(hour: 14, minute: 30),
        endDate: dateToday(hour: 16, minute: 30),
        category: "интерактив",
        zoneID: "zone-003",
        festivalID: "youngcon-2026",
        streamURL: nil
    ),

    Event(
        id: "event-004",
        title: "ML в рекомендательных системах Музыки",
        description: "Под капотом Моей Волны.",
        startDate: dateToday(hour: 17, minute: 0),
        endDate: dateToday(hour: 18, minute: 30),
        category: "ml",
        zoneID: "zone-004",
        festivalID: "youngcon-2026",
        streamURL: nil
    )
]
