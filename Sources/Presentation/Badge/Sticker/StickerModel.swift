import SwiftUI

struct Sticker: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String
    let isUnlocked: Bool
    let bgColor: Color
    let fgColor: Color
    let description: String
}

/// Расширение добавляет новый способ создания стикера из данных API
extension Sticker {
    init(from achievement: Achievement, isUnlocked: Bool) {
        id = achievement.id
        name = achievement.name
        description = achievement.description
        // Если иконка не пришла, ставим заглушку
        icon = achievement.icon.isEmpty ? "star.fill" : achievement.icon
        self.isUnlocked = isUnlocked

        if isUnlocked {
            // Если разблокирована - парсим цвет из строки Hex (например "#FF0000")
            bgColor = Color(hex: achievement.color)
            fgColor = .white
        } else {
            // Если заблокирована - красим в серый
            // Если YoungConAsset недоступен в этом файле, используйте Color.gray.opacity(0.3)
            bgColor = YoungConAsset.gray700.swiftUIColor
            fgColor = YoungConAsset.gray500.swiftUIColor
        }
    }
}
