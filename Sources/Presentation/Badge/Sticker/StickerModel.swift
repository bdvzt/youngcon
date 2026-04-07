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
        icon = URL(string: achievement.icon ?? "")
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
