import Foundation

struct ZoneDTO: Decodable {
    let id: String
    let floorId: String
    let title: String
    let description: String
    let cordX: Double?
    let cordY: Double?
    let icon: String
    let color: String

    private enum CodingKeys: String, CodingKey {
        case id
        case floorID
        case floorId
        case title
        case description
        case cordX
        case cordY
        case cord_x
        case cord_y
        case icon
        case color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        floorID = try container.decodeIfPresent(String.self, forKey: .floorID) ??
            container.decode(String.self, forKey: .floorId)

        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)

        cordX = try container.decodeIfPresent(Double.self, forKey: .cordX) ??
            container.decodeIfPresent(Double.self, forKey: .cord_x)
        cordY = try container.decodeIfPresent(Double.self, forKey: .cordY) ??
            container.decodeIfPresent(Double.self, forKey: .cord_y)

        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? ""
        color = try container.decode(String.self, forKey: .color)
    }
}

extension ZoneDTO {
    func toEntity() -> Zone? {
        Zone(
            id: id,
            floorID: floorId,
            title: title,
            description: description,
            cordX: cordX,
            cordY: cordY,
            icon: icon,
            color: color.toColor()
        )
    }
}
