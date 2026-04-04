import Foundation

struct EventDetailedCardModel {
    let title: String
    let time: String
    let location: String
    let description: String
    let speakerName: String
    let speakerRole: String
    let primaryActionTitle: String
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
        primaryActionTitle: "ТРАНСЛЯЦИЯ"
    )
}
