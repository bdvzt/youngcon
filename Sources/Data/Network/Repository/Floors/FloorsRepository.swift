final class FloorsRepository: FloorsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getFloor(id: String) async throws -> Floor {
        let endpoint = GetFloorByIDEndpoint(id)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: FloorDTO.self
        )
        guard let floor = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return floor
    }

    func getFloors() async throws -> [Floor] {
        let endpoint = GetFloorsEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [FloorDTO].self
        ).compactMap { $0.toEntity() }
    }
}
