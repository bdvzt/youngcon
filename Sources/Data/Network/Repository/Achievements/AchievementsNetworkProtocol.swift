protocol AchievementsNetworkProtocol {
    func getAchievements() async throws -> [Achievement]
}
