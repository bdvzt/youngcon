import Foundation

struct Floor: Identifiable, Decodable {
    let id: String
    let title: String
    let mapURL: String

    var mapImageURL: URL? {
        URL(string: mapURL)
    }
}
