import Foundation

struct EventDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let startDateTime: String
    let endDateTime: String
    let category: String
    let zoneID: String
    let festivalID: String
    let streamURL: String?
}

extension EventDTO {
    var startDate: Date? {
        startDateTime.toISODate()
    }

    var endDate: Date? {
        endDateTime.toISODate()
    }

    func toEntity() -> Event? {
        guard let startDate,
              let endDate
        else {
            return nil
        }

        return Event(
            id: id,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            category: category,
            zoneID: zoneID,
            festivalID: festivalID,
            streamURL: streamURL.flatMap { URL(string: $0) }
        )
    }
}
