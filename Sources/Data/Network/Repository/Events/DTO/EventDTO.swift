import Foundation

struct EventDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let startDateTime: String
    let endDateTime: String
    let category: String
    let zoneId: String
    let festivalId: String
    let streamURL: String?
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case startDateTime
        case endDateTime
        case category
        case zoneID
        case zoneId
        case festivalID
        case festivalId
        case streamURL
        case streamUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        startDateTime = try container.decode(String.self, forKey: .startDateTime)
        endDateTime = try container.decode(String.self, forKey: .endDateTime)
        category = try container.decode(String.self, forKey: .category)
        zoneID = try container.decodeIfPresent(String.self, forKey: .zoneID)
            ?? container.decode(String.self, forKey: .zoneId)
        festivalID = try container.decodeIfPresent(String.self, forKey: .festivalID)
            ?? container.decode(String.self, forKey: .festivalId)
        streamURL = try container.decodeIfPresent(String.self, forKey: .streamURL)
    }
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
            zoneID: zoneId,
            festivalID: festivalId,
            streamURL: streamURL.flatMap { URL(string: $0) }
        )
    }
}
