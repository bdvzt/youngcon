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
        icon = achievement.icon
        self.isUnlocked = isUnlocked

        if isUnlocked {
            bgColor = achievement.color
            fgColor = .white
        } else {
            bgColor = AppColor.gray700
            fgColor = AppColor.gray500
        }
    }
}
