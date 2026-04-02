import Foundation

struct Floor: Identifiable, Codable {
    let id: UUID
    let title: String
    let mapImageURL: URL
    let zoneIDs: [UUID]
}
