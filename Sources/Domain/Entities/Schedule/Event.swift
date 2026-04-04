import Foundation

struct Event: Identifiable, Decodable {
    let id: String
    let title: String
    let description: String
    let startDateTime: String
    let endDateTime: String
    let category: String
    let zoneID: String
    let festivalID: String

    var startDate: Date? {
        startDateTime.toISODate()
    }

    var endDate: Date? {
        endDateTime.toISODate()
    }
}
