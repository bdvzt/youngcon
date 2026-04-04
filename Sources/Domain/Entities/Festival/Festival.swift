import Foundation

struct Festival: Decodable {
    let id: String
    let title: String
    let description: String
    let startDateTime: String
    let endDateTime: String

    var startDate: Date? {
        startDateTime.toISODate()
    }

    var endDate: Date? {
        endDateTime.toISODate()
    }
}
