extension NetworkService: UsersNetworkProtocol {
    func getMyProfile() async throws -> UserProfile {
        let endpoint = GetUserProfileEndpoint()
        return try await requestDecodable(
            endpoint,
            as: UserProfile.self
        )
    }

    func getUserLikedEvents(userID: String) async throws -> [Event] {
        let endpoint = GetUserLikedEventsEndpoint(userID)
        return try await requestDecodable(
            endpoint,
            as: [Event].self
        )
    }

    func getUserAchievements(userID: String) async throws -> [Achievement] {
        let endpoint = GetUserAchievmentsEndpoint(userID)
        return try await requestDecodable(
            endpoint,
            as: [Achievement].self
        )
    }
}
