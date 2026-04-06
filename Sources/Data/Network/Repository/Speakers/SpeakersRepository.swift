final class SpeakersRepository: SpeakersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSpeaker(speakerID: String) async throws -> Speaker {
        let endpoint = GetSpeakerByIDEndpoint(speakerID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: SpeakerDTO.self
        )
        guard let speaker = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return speaker
    }

    func getAllSpeakers() async throws -> [Speaker] {
        let endpoint = GetSpeakersEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [SpeakerDTO].self
        ).compactMap { $0.toEntity() }
    }
}
