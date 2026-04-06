final class UsersRepository: UsersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getMyProfile() async throws -> UserProfile {
        let endpoint = GetUserProfileEndpoint()
        let response = try await networkService.requestDecodable(
            endpoint,
            as: UserProfileDTO.self
        )
        guard let user = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return user
    }

    func getUserLikedEvents(userID: String) async throws -> [Event] {
        let endpoint = GetUserLikedEventsEndpoint(userID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func getUserAchievements(userID: String) async throws -> [Achievement] {
        let endpoint = GetUserAchievmentsEndpoint(userID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [AchievementDTO].self
        ).compactMap { $0.toEntity() }
    }
}
