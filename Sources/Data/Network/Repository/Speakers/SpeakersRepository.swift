final class SpeakersRepository: SpeakersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSpeaker(speakerID: String) async throws -> Speaker {
        let endpoint = GetSpeakerByIDEndpoint(speakerID)
        return try await networkService.requestDecodable(
            endpoint,
            as: Speaker.self
        )
    }

    func getAllSpeakers() async throws -> [Speaker] {
        let endpoint = GetSpeakersEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [Speaker].self
        )
    }
}
