import Foundation

struct FestivalDTO: Codable {
    let id: String
    let title: String
    let description: String
    let startDateTime: String
    let endDateTime: String
}

extension FestivalDTO {
    var startDate: Date? {
        startDateTime.toISODate()
    }

    var endDate: Date? {
        endDateTime.toISODate()
    }

    func toEntity() -> Festival? {
        guard let startDate,
              let endDate
        else {
            return nil
        }

        return Festival(
            id: id,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate
        )
    }
}
