protocol ZoneRepositoryProtocol {
    func getZone(zoneID: String) async throws -> Zone
    func getZones(floorID: String) async throws -> [Zone]
}
