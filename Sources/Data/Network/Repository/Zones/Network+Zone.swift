extension NetworkService: ZoneNetworkProtocol {
    func getZone(zoneID: String) async throws -> Zone {
        let endpoint = GetZoneByIDEndpoint(zoneID)
        return try await requestDecodable(
            endpoint,
            as: Zone.self
        )
    }

    func getZone(floorID: String) async throws -> Zone {
        let endpoint = GetZonesByFloorIDEndpoint(floorID)
        return try await requestDecodable(
            endpoint,
            as: Zone.self
        )
    }
}
