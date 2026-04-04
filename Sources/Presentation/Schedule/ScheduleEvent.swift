import SwiftUI

struct ScheduleModel: Identifiable {
    let id: Int
    let time: String
    let title: String
    let speaker: String
    let role: String
    let location: String
    let tags: [String]
    let streamAvailable: Bool
    let description: String
    let speakerBio: String
}

let scheduleData: [ScheduleModel] = [
    ScheduleModel(
        id: 1, time: "11:00 – 12:30",
        title: "Открытие YoungCon: Будущее бигтеха",
        speaker: "Топ-менеджмент Яндекса", role: "Ключевые спикеры",
        location: "LIVE Арена (Главная)", tags: ["Лекция", "Бизнес", "Main"],
        streamAvailable: true,
        description:
        "Ежегодное открытие фестиваля. Поговорим о том, куда движутся технологии.",
        speakerBio: "Лидеры направлений, визионеры и создатели ключевых продуктов."
    ),
    ScheduleModel(
        id: 2, time: "13:00 – 14:00",
        title: "Как мы переписали бэкенд на Go и выжили",
        speaker: "Алексей Смирнов", role: "Lead Backend Engineer, Yandex Go",
        location: "Лекторий B", tags: ["Hardcore", "Backend"],
        streamAvailable: true,
        description: "Реальный кейс перехода с монолита на микросервисы. Разберем ошибки и архитектурные решения",
        speakerBio: "Алексей имеет 10+ лет опыта в бэкенд-разработке."
    ),
    ScheduleModel(
        id: 3, time: "14:30 – 16:00",
        title: "Дизайн-ревью: Приноси свои макеты",
        speaker: "Команда дизайна Поиска", role: "UX/UI Designers",
        location: "Воркшоп зона", tags: ["Интерактив", "Дизайн"],
        streamAvailable: false,
        description: "Разбираем работы участников в прямом эфире. Честный фидбек, советы по композиции и сеткам.",
        speakerBio: "Команда экспертов, отвечающая за визуальный язык крупнейшего поисковика."
    ),
    ScheduleModel(
        id: 4, time: "16:30 – 17:30",
        title: "ML в рекомендательных системах Музыки",
        speaker: "Елена Кузнецова", role: "Data Scientist, Яндекс Музыка",
        location: "Лекторий А", tags: ["ML", "Лекция"],
        streamAvailable: true,
        description:
        "Под капотом Моей Волны. Как мы анализируем миллионы прослушиваний и угадываем настроение пользователя с первых нот.",
        speakerBio: "Лена разрабатывает ML-модели, которые заставляют пользователей говорить 'Ого, откуда они знают?'."
    ),
]
