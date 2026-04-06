import Foundation

struct ScheduleEntry: Identifiable {
    let id: String
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]
    let streamURL: URL?
}

private let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
}()

private func isoToday(hour: Int, minute: Int) -> String {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute
    components.second = 0
    let date = Calendar.current.date(from: components) ?? Date()
    return isoFormatter.string(from: date)
}

let scheduleData: [ScheduleEntry] = [
    ScheduleEntry(
        id: "event-001",
        event: Event(
            id: "event-001",
            title: "Открытие YoungCon: Будущее бигтеха",
            description: "Ежегодное открытие фестиваля. Поговорим о том, куда движутся технологии.",
            startDateTime: isoFormatter.string(from: Date().addingTimeInterval(-30 * 60)),
            endDateTime: isoFormatter.string(from: Date().addingTimeInterval(90 * 60)),
            category: "лекция",
            zoneID: "zone-001",
            festivalID: "youngcon-2026"
        ),
        zone: Zone(
            id: "zone-001",
            floorID: "floor-1",
            title: "LIVE Арена (Главная)",
            description: "Главная сцена фестиваля",
            icon: "mappin.circle.fill",
            color: "pink"
        ),
        speakers: [
            Speaker(
                id: "speaker-001",
                fullName: "Топ-менеджмент Яндекса",
                job: "Ключевые спикеры",
                bio: "Лидеры направлений.",
                avatarURL: nil
            ),
        ],
        streamURL: URL(string: "https://stream.example.com/event-001")
    ),

    ScheduleEntry(
        id: "event-002",
        event: Event(
            id: "event-002",
            title: "Как мы переписали бэкенд на Go и выжили",
            description: "Реальный кейс перехода с монолита на микросервисы.",
            startDateTime: isoFormatter.string(from: Date().addingTimeInterval(-10 * 60)),
            endDateTime: isoFormatter.string(from: Date().addingTimeInterval(50 * 60)),
            category: "backend",
            zoneID: "zone-002",
            festivalID: "youngcon-2026"
        ),
        zone: Zone(
            id: "zone-002",
            floorID: "floor-1",
            title: "Лекторий B",
            description: "Лекционный зал B",
            icon: "mappin.circle.fill",
            color: "indigo"
        ),
        speakers: [
            Speaker(
                id: "speaker-002",
                fullName: "Алексей Смирнов",
                job: "Lead Backend Engineer",
                bio: "Эксперт бэкенда.",
                avatarURL: nil
            ),
        ],
        streamURL: URL(string: "https://stream.example.com/event-002")
    ),

    ScheduleEntry(
        id: "event-003",
        event: Event(
            id: "event-003",
            title: "Дизайн-ревью: Приноси свои макеты",
            description: "Разбираем работы участников в прямом эфире.",
            startDateTime: isoFormatter.string(from: Date().addingTimeInterval(120 * 60)),
            endDateTime: isoFormatter.string(from: Date().addingTimeInterval(180 * 60)),
            category: "интерактив",
            zoneID: "zone-003",
            festivalID: "youngcon-2026"
        ),
        zone: Zone(
            id: "zone-003",
            floorID: "floor-2",
            title: "Воркшоп зона",
            description: "Интерактивная зона",
            icon: "paintbrush.pointed.fill",
            color: "orange"
        ),
        speakers: [
            Speaker(
                id: "speaker-003",
                fullName: "Команда дизайна",
                job: "UX/UI Designers",
                bio: "Эксперты.",
                avatarURL: nil
            ),
        ],
        streamURL: nil
    ),

    ScheduleEntry(
        id: "event-004",
        event: Event(
            id: "event-004",
            title: "ML в рекомендательных системах Музыки",
            description: "Под капотом Моей Волны.",
            startDateTime: isoFormatter.string(from: Date().addingTimeInterval(240 * 60)),
            endDateTime: isoFormatter.string(from: Date().addingTimeInterval(300 * 60)),
            category: "ml",
            zoneID: "zone-004",
            festivalID: "youngcon-2026"
        ),
        zone: Zone(
            id: "zone-004",
            floorID: "floor-1",
            title: "Лекторий А",
            description: "Лекционный зал А",
            icon: "mappin.circle.fill",
            color: "purple"
        ),
        speakers: [
            Speaker(
                id: "speaker-004",
                fullName: "Елена Кузнецова",
                job: "Data Scientist",
                bio: "ML эксперт.",
                avatarURL: nil
            ),
        ],
        streamURL: nil
    ),
]
