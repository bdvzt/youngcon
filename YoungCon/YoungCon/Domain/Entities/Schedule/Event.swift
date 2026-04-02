import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let start: Date
    let end: Date
    let speakerIDs: [UUID] // Может быть больше одного спикера
    let zoneID: UUID?
    let categoryCode: String
    let streamURL: URL?
}
