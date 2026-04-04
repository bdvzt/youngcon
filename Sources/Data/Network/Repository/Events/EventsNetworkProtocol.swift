import Foundation

protocol EventsNetworkProtocol {
    func getEvents(festivalID: String) async throws -> [Event]
    func getEvent(eventID: String) async throws -> Event
    func getZoneEvents(zoneID: String) async throws -> [Event]
    func getSpeakerEvents(speakerID: String) async throws -> [Event]
    func likeEvent(eventID: String) async throws -> LikeEventResponse
}
