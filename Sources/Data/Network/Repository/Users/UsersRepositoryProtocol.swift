protocol UsersRepositoryProtocol {
    func getMyProfile(policy: CachePolicy) async throws -> UserProfile
    func getUserLikedEvents(
        userID: String,
        policy: CachePolicy
    ) async throws -> [Event]
    func getUserAchievements(
        userID: String,
        policy: CachePolicy
    ) async throws -> [Achievement]
}
