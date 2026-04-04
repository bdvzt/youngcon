protocol UsersNetworkProtocol {
    func getMyProfile() async throws -> UserProfile
    func getUserLikedEvents(userID: String) async throws -> [Event]
    func getUserAchievements(userID: String) async throws -> [Achievement]
}
