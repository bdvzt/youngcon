protocol ZoneRepositoryProtocol {
    func getZone(zoneID: String, policy: CachePolicy) async throws -> Zone
    func getZones(floorID: String, policy: CachePolicy) async throws -> [Zone]
}
