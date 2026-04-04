extension NetworkService: FestivalsNetworkProtocol {
    func getLastFestival() async throws -> Festival {
        let endpoint = GetLastFestivalEndpoint()
        return try await requestDecodable(
            endpoint,
            as: Festival.self
        )
    }
}
