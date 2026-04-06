import SwiftUI

struct LocationModel: Identifiable, Equatable {
    let id: String
    let title: String
    let iconName: String
    let color: Color
    let topPercent: CGFloat
    let leftPercent: CGFloat
    let floor: Int
    let description: String
}

let mapLocationsData: [LocationModel] = [
    LocationModel(
        id: "main", title: "Главная сцена", iconName: "mic.fill",
        color: YoungConAsset.accentYellow.swiftUIColor,
        topPercent: 0.25, leftPercent: 0.35, floor: 1,
        description: "Ключевые выступления, открытие и хедлайнеры YoungCon."
    ),
    LocationModel(
        id: "food", title: "Фуд-корт", iconName: "cup.and.saucer.fill",
        color: YoungConAsset.accentPink.swiftUIColor,
        topPercent: 0.75, leftPercent: 0.25, floor: 1,
        description: "Кофе-споты и быстрые перекусы между сессиями."
    ),
    LocationModel(
        id: "chill", title: "Зона отдыха", iconName: "gamecontroller.fill",
        color: YoungConAsset.accentPurple.swiftUIColor,
        topPercent: 0.65, leftPercent: 0.60, floor: 2,
        description: "Лаунж, настолки и неформальный нетворкинг."
    ),
    LocationModel(
        id: "lect", title: "Лектории А и В", iconName: "mappin.fill",
        color: YoungConAsset.accentPurple.swiftUIColor,
        topPercent: 0.35, leftPercent: 0.50, floor: 2,
        description: "Потоковые доклады по разработке, дизайну и ML."
    ),
    LocationModel(
        id: "hack", title: "Зона Вузов",
        iconName: "chevron.left.forwardslash.chevron.right",
        color: .white,
        topPercent: 0.55, leftPercent: 0.55, floor: 1,
        description: "Стенды университетов и программы стажировок."
    ),
]
