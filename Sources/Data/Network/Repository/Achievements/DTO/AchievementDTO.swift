import Foundation

struct AchievementDTO: Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: String
}

extension AchievementDTO {
    func toEntity() -> Achievement {
        Achievement(
            id: id,
            name: name,
            description: description,
            icon: URL(string: icon),
            color: color.toColor()
        )
    }
}
