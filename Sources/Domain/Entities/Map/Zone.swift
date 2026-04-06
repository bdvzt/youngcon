import Foundation

struct Zone: Identifiable, Decodable {
    let id: String
    let floorID: String
    let title: String
    let description: String
    let icon: String
    let color: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, icon, color
        case floorID = "floorId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        floorID = try container.decode(String.self, forKey: .floorID)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? ""
        color = try container.decodeIfPresent(String.self, forKey: .color) ?? ""
    }
}
