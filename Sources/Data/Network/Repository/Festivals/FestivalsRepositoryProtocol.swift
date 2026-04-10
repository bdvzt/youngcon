protocol FestivalsRepositoryProtocol {
    func getLastFestival(policy: CachePolicy) async throws -> Festival
}
