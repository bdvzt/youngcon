final class ZoneRepository: ZoneRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getZone(zoneID: String) async throws -> Zone {
        let endpoint = GetZoneByIDEndpoint(zoneID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: ZoneDTO.self
        )
        guard let zone = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return zone
    }

    func getZones(floorID: String) async throws -> [Zone] {
        let endpoint = GetZonesByFloorIDEndpoint(floorID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [ZoneDTO].self
        ).compactMap { $0.toEntity() }
    }
}
