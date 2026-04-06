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

    enum CodingKeys: String, CodingKey {
        case id, title, description, startDateTime, endDateTime, category
        case zoneID = "zoneId"
        case festivalID = "festivalId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        startDateTime = try container.decode(String.self, forKey: .startDateTime)
        endDateTime = try container.decode(String.self, forKey: .endDateTime)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        zoneID = try container.decodeIfPresent(String.self, forKey: .zoneID) ?? ""
        festivalID = try container.decode(String.self, forKey: .festivalID)
    }
}
