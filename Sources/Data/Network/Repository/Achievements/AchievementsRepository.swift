final class AchievementsRepository: AchievementsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getAchievements() async throws -> [Achievement] {
        let endpoint = GetAchievmentsEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [AchievementDTO].self
        ).compactMap { $0.toEntity() }
    }
}
