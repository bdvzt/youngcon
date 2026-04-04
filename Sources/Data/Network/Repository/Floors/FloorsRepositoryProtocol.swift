protocol FloorsRepositoryProtocol {
    func getFloor(id: String) async throws -> Floor
    func getFloors() async throws -> [Floor]
}
