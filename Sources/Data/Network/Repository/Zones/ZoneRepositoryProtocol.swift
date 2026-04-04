protocol ZoneRepositoryProtocol {
    func getZone(zoneID: String) async throws -> Zone
    func getZone(floorID: String) async throws -> Zone
}
