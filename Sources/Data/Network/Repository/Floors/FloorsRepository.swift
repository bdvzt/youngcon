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

final class CachedFloorsRepository: FloorsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: ScheduleCacheStoreProtocol

    init(networkService: NetworkServiceProtocol, cacheStore: ScheduleCacheStoreProtocol) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getFloor(id: String) async throws -> Floor {
        if let cachedDTO = try? await cacheStore.load(FloorDTO.self, for: CacheKey.Schedule.floor(floorID: id)),
           let floor = cachedDTO.toEntity()
        {
            return floor
        }

        do {
            let endpoint = GetFloorByIDEndpoint(id)
            let dto = try await networkService.requestDecodable(endpoint, as: FloorDTO.self)
            try? await cacheStore.save(dto, for: CacheKey.Schedule.floor(floorID: id))
            if let floor = dto.toEntity() {
                return floor
            }
            throw NetworkError.decodingFailed
        } catch {
            if let cachedDTO = try? await cacheStore.load(FloorDTO.self, for: CacheKey.Schedule.floor(floorID: id)),
               let floor = cachedDTO.toEntity()
            {
                return floor
            }
            throw error
        }
    }

    func getFloors() async throws -> [Floor] {
        if let cachedDTOs = try? await cacheStore.load([FloorDTO].self, for: CacheKey.Schedule.allFloors) {
            return cachedDTOs.compactMap { $0.toEntity() }
        }

        do {
            let endpoint = GetFloorsEndpoint()
            let dtos = try await networkService.requestDecodable(endpoint, as: [FloorDTO].self)
            try? await cacheStore.save(dtos, for: CacheKey.Schedule.allFloors)
            return dtos.compactMap { $0.toEntity() }
        } catch {
            if let cachedDTOs = try? await cacheStore.load([FloorDTO].self, for: CacheKey.Schedule.allFloors) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }
            throw error
        }
    }
}
