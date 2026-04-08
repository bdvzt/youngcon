import Foundation

struct EventDetailedCardModel {
    let title: String
    let time: String
    let location: String
    let description: String
    let speakerName: String
    let speakerRole: String
    let primaryActionTitle: String
    let speaker: Speaker
}

extension EventDetailedCardModel {
    static let mock = EventDetailedCardModel(
        title: "ОТКРЫТИЕ YOUNGCON:\nБУДУЩЕЕ БИГТЕХА",
        time: "11:00 - 12:30",
        location: "LIVE Арена (Главная)",
        description: "Ежегодное открытие фестиваля. "
            + "Поговорим о том, куда движутся технологии, "
            + "какие навыки будут востребованы через 5 лет "
            + "и как ИИ меняет наши продукты прямо сейчас.",
        speakerName: "Топ-менеджмент\nЯндекса",
        speakerRole: "КЛЮЧЕВЫЕ СПИКЕРЫ",
        primaryActionTitle: "ТРАНСЛЯЦИЯ",
        speaker: Speaker(
            id: "1",
            fullName: "Анна Иванова",
            job: "Директор по продукту, Яндекс",
            bio: """
            Лидеры направлений, визионеры и создатели ключевых продуктов. 
            Они задают тренды в индустрии, формируют вектор развития технологий 
            и знают, как построить сервисы, которыми будут пользоваться 
            миллионы людей каждый день.
            """,
            avatarImageURL: nil
        )
    )
}
