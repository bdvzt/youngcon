final class FestivalsRepository: FestivalsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getLastFestival() async throws -> Festival {
        let endpoint = GetLastFestivalEndpoint()
        let response = try await networkService.requestDecodable(
            endpoint,
            as: FestivalDTO.self
        )
        guard let festival = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return festival
    }
}
