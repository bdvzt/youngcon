import Foundation

struct FloorDTO: Decodable {
    let id: String
    let title: String
    let mapURL: String
}

extension FloorDTO {
    func toEntity() -> Floor? {
        guard let mapImageURL = URL(string: mapURL) else {
            return nil
        }

        return Floor(
            id: id,
            title: title,
            mapImageURL: mapImageURL
        )
    }
}
