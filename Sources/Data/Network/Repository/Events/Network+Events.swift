extension NetworkService: EventsNetworkProtocol {
    func getEvents(festivalID: String) async throws -> [Event] {
        let endpoint = GetEventsEndpoint(festivalID)
        return try await requestDecodable(
            endpoint,
            as: [Event].self
        )
    }

    func getEvent(eventID: String) async throws -> Event {
        let endpoint = GetEventByIDEndpoint(eventID)
        return try await requestDecodable(
            endpoint,
            as: Event.self
        )
    }

    func getZoneEvents(zoneID: String) async throws -> [Event] {
        let endpoint = GetZoneEventsEndpoint(zoneID)
        return try await requestDecodable(
            endpoint,
            as: [Event].self
        )
    }

    func getSpeakerEvents(speakerID: String) async throws -> [Event] {
        let endpoint = GetSpeakerEventsEndpoint(speakerID)
        return try await requestDecodable(
            endpoint,
            as: [Event].self
        )
    }

    func likeEvent(eventID: String) async throws -> LikeEventResponse {
        let endpoint = LikeEventEndpoint(eventID)
        return try await requestDecodable(
            endpoint,
            as: LikeEventResponse.self
        )
    }
}
