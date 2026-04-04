import Foundation

// MARK: - Schedule Entry

struct ScheduleEntry: Identifiable {
    let id: String
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]
    let streamURL: URL?
}

// MARK: - Helpers

private let isoFormatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
}()

private func isoToday(hour: Int, minute: Int) -> String {
    var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    c.hour = hour; c.minute = minute; c.second = 0
    let date = Calendar.current.date(from: c) ?? Date()
    return isoFormatter.string(from: date)
}

// MARK: - Data

let scheduleData: [ScheduleEntry] = [

    ScheduleEntry(
        id: "event-001",
        event: Event(
            id: "event-001",
            title: "Открытие YoungCon: Будущее бигтеха",
            description: "Ежегодное открытие фестиваля. Поговорим о том, куда движутся технологии.",
            startDateTime: isoToday(hour: 11, minute: 0),
            endDateTime:   isoToday(hour: 12, minute: 30),
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
                bio: "Лидеры направлений, визионеры и создатели ключевых продуктов.",
                avatarURL: nil
            )
        ],
        streamURL: URL(string: "https://stream.example.com/event-001")
    ),

    ScheduleEntry(
        id: "event-002",
        event: Event(
            id: "event-002",
            title: "Как мы переписали бэкенд на Go и выжили",
            description: "Реальный кейс перехода с монолита на микросервисы. Разберем ошибки и архитектурные решения.",
            startDateTime: isoToday(hour: 13, minute: 0),
            endDateTime:   isoToday(hour: 14, minute: 0),
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
                job: "Lead Backend Engineer, Yandex Go",
                bio: "Алексей имеет 10+ лет опыта в бэкенд-разработке.",
                avatarURL: nil
            )
        ],
        streamURL: URL(string: "https://stream.example.com/event-002")
    ),

    ScheduleEntry(
        id: "event-003",
        event: Event(
            id: "event-003",
            title: "Дизайн-ревью: Приноси свои макеты",
            description: "Разбираем работы участников в прямом эфире. Честный фидбек, советы по композиции.",
            startDateTime: isoToday(hour: 14, minute: 30),
            endDateTime:   isoToday(hour: 16, minute: 0),
            category: "интерактив",
            zoneID: "zone-003",
            festivalID: "youngcon-2026"
        ),
        zone: Zone(
            id: "zone-003",
            floorID: "floor-2",
            title: "Воркшоп зона",
            description: "Интерактивная зона для воркшопов",
            icon: "paintbrush.pointed.fill",
            color: "orange"
        ),
        speakers: [
            Speaker(
                id: "speaker-003",
                fullName: "Команда дизайна Поиска",
                job: "UX/UI Designers",
                bio: "Команда экспертов, отвечающая за визуальный язык крупнейшего поисковика.",
                avatarURL: nil
            )
        ],
        streamURL: nil
    ),

    ScheduleEntry(
        id: "event-004",
        event: Event(
            id: "event-004",
            title: "ML в рекомендательных системах Музыки",
            description: "Под капотом Моей Волны. Как мы анализируем миллионы прослушиваний.",
            startDateTime: isoToday(hour: 16, minute: 30),
            endDateTime:   isoToday(hour: 17, minute: 30),
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
                job: "Data Scientist, Яндекс Музыка",
                bio: "Разрабатывает ML-модели, которые угадывают настроение пользователя с первых нот.",
                avatarURL: nil
            )
        ],
        streamURL: URL(string: "https://stream.example.com/event-004")
    ),
]
