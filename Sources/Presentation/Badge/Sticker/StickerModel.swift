import SwiftUI

struct Sticker: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: URL?
    let isUnlocked: Bool
    let bgColor: Color
    let fgColor: Color
    let description: String
}

extension Sticker {
    init(from achievement: Achievement, isUnlocked: Bool) {
        id = achievement.id
        name = achievement.name
        description = achievement.description

        // Правильное создание URL из строки
        if let iconString = achievement.icon, !iconString.isEmpty {
            icon = URL(string: iconString)
        } else {
            icon = nil // или можно создать URL из системного имени, но это не сработает
        }

        self.isUnlocked = isUnlocked

        if isUnlocked {
            bgColor = Color.from(hex: achievement.color, defaultValue: YoungConAsset.gray700.swiftUIColor)
            fgColor = .white
        } else {
            bgColor = YoungConAsset.gray700.swiftUIColor
            fgColor = YoungConAsset.gray500.swiftUIColor
        }
    }
}
