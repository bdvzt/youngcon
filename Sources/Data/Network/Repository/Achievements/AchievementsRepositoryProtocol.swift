protocol AchievementsRepositoryProtocol {
    func getAchievements(policy: CachePolicy) async throws -> [Achievement]
}
