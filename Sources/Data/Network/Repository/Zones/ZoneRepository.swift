final class ZoneRepository: ZoneRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getZone(zoneID: String) async throws -> Zone {
        let endpoint = GetZoneByIDEndpoint(zoneID)
        return try await networkService.requestDecodable(
            endpoint,
            as: Zone.self
        )
    }

    func getZone(floorID: String) async throws -> Zone {
        let endpoint = GetZonesByFloorIDEndpoint(floorID)
        return try await networkService.requestDecodable(
            endpoint,
            as: Zone.self
        )
    }
}
