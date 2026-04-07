import Foundation

struct ZoneDTO: Decodable {
    let id: String
    let floorId: String
    let title: String
    let description: String
    let coordX: Double
    let coordY: Double
    let icon: String
    let color: String
}

extension ZoneDTO {
    func toEntity() -> Zone? {
        guard let iconURL = URL(string: icon) else {
            return nil
        }

        return Zone(
            id: id,
            floorID: floorId,
            title: title,
            description: description,
            cordX: coordX,
            cordY: coordY,
            icon: iconURL,
            color: color.toColor()
        )
    }
}
