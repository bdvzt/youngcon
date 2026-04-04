protocol AchievementsRepositoryProtocol {
    func getAchievements() async throws -> [Achievement]
}
