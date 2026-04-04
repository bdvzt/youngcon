extension NetworkService: FloorsNetworkProtocol {
    func getFloor(id: String) async throws -> Floor {
        let endpoint = GetFloorByIDEndpoint(id)
        return try await requestDecodable(
            endpoint,
            as: Floor.self
        )
    }

    func getFloors() async throws -> [Floor] {
        let endpoint = GetFloorsEndpoint()
        return try await requestDecodable(
            endpoint,
            as: [Floor].self
        )
    }
}
