import Foundation

struct ZoneDTO: Decodable {
    let id: String
    let floorID: String
    let title: String
    let description: String
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
            floorID: floorID,
            title: title,
            description: description,
            icon: iconURL,
            color: color.toColor()
        )
    }
}
