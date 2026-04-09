protocol FloorsRepositoryProtocol {
    func getFloor(id: String, policy: CachePolicy) async throws -> Floor
    func getFloors(policy: CachePolicy) async throws -> [Floor]
}
