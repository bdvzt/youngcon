import Foundation

struct Event: Identifiable {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let category: String
    let zoneID: String
    let festivalID: String
    let streamURL: URL?
}
