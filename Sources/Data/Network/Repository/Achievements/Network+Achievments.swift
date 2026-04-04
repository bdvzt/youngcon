extension NetworkService: AchievementsNetworkProtocol {
    func getAchievements() async throws -> [Achievement] {
        let endpoint = GetAchievmentsEndpoint()
        return try await requestDecodable(
            endpoint,
            as: [Achievement].self
        )
    }
}
