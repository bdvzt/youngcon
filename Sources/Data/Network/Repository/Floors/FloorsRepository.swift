final class FloorsRepository: FloorsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getFloor(id: String) async throws -> Floor {
        let endpoint = GetFloorByIDEndpoint(id)
        return try await networkService.requestDecodable(
            endpoint,
            as: Floor.self
        )
    }

    func getFloors() async throws -> [Floor] {
        let endpoint = GetFloorsEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [Floor].self
        )
    }
}
