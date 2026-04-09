import Foundation

private struct UserAchievementsResponse: Decodable {
    let userId: String
    let achievments: [AchievementDTO]
}

private struct UserLikedEventsResponse: Decodable {
    let userId: String
    let likedEvents: [EventDTO]
}

final class UsersRepository: UsersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getMyProfile() async throws -> UserProfile {
        let endpoint = GetUserProfileEndpoint()
        let dto = try await networkService.requestDecodable(
            endpoint,
            as: UserProfileDTO.self
        )
        guard let profile = dto.toEntity() else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Failed to map UserProfileDTO to UserProfile")
            )
        }
        return profile
    }

    func getUserLikedEvents(userID: String) async throws -> [Event] {
        let endpoint = GetUserLikedEventsEndpoint(userID)
        if let wrappedResponse = try? await networkService.requestDecodable(
            endpoint,
            as: UserLikedEventsResponse.self
        ) {
            return wrappedResponse.likedEvents.compactMap { $0.toEntity() }
        }

        let plainResponse = try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        )
        return plainResponse.compactMap { $0.toEntity() }
    }

    func getUserAchievements(userID: String) async throws -> [Achievement] {
        let endpoint = GetUserAchievmentsEndpoint(userID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: UserAchievementsResponse.self
        )
        return response.achievments.map { $0.toEntity() }
    }
}
