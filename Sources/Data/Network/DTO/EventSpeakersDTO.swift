import Foundation

struct EventSpeakersDTO: Decodable {
    let eventID: String
    let speakers: [Speaker]?

    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
        case speakers
    }
}
