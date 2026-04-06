final class EventsRepository: EventsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getEvents(festivalID: String) async throws -> [Event] {
        let endpoint = GetEventsEndpoint(festivalID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func getEvent(eventID: String) async throws -> Event {
        let endpoint = GetEventByIDEndpoint(eventID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: EventDTO.self
        )
        guard let event = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return event
    }

    func getZoneEvents(zoneID: String) async throws -> [Event] {
        let endpoint = GetZoneEventsEndpoint(zoneID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func getSpeakerEvents(speakerID: String) async throws -> [Event] {
        let endpoint = GetSpeakerEventsEndpoint(speakerID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func likeEvent(eventID: String) async throws -> LikeEventResponse {
        let endpoint = LikeEventEndpoint(eventID)
        return try await networkService.requestDecodable(
            endpoint,
            as: LikeEventResponse.self
        )
    }
}
