extension NetworkService: SpeakersNetworkProtocol {
    func getSpeaker(speakerID: String) async throws -> Speaker {
        let endpoint = GetSpeakerByIDEndpoint(speakerID)
        return try await requestDecodable(
            endpoint,
            as: Speaker.self
        )
    }

    func getAllSpeakers() async throws -> [Speaker] {
        let endpoint = GetSpeakersEndpoint()
        return try await requestDecodable(
            endpoint,
            as: [Speaker].self
        )
    }
}
