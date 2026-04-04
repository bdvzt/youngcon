final class FestivalsRepository: FestivalsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getLastFestival() async throws -> Festival {
        let endpoint = GetLastFestivalEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: Festival.self
        )
    }
}
