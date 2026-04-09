final class FloorsRepository: FloorsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getFloor(id: String, policy _: CachePolicy) async throws -> Floor {
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

    func getFloors(policy _: CachePolicy) async throws -> [Floor] {
        let endpoint = GetFloorsEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [FloorDTO].self
        ).compactMap { $0.toEntity() }
    }
}

final class CachedFloorsRepository: FloorsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: MapCacheStoreProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheStore: MapCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getFloor(id: String, policy: CachePolicy) async throws -> Floor {
        let key = CacheKey.Map.floor(floorID: id)

        switch policy {
        case .cacheFirst:
            if let cachedDTO = try? await cacheStore.load(FloorDTO.self, for: key),
               let floor = cachedDTO.toEntity()
            {
                return floor
            }

            let endpoint = GetFloorByIDEndpoint(id)
            let dto = try await networkService.requestDecodable(endpoint, as: FloorDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let floor = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return floor

        case .networkFirst:
            do {
                let endpoint = GetFloorByIDEndpoint(id)
                let dto = try await networkService.requestDecodable(endpoint, as: FloorDTO.self)
                try? await cacheStore.save(dto, for: key)

                guard let floor = dto.toEntity() else {
                    throw NetworkError.decodingFailed
                }
                return floor
            } catch {
                if let cachedDTO = try? await cacheStore.load(FloorDTO.self, for: key),
                   let floor = cachedDTO.toEntity()
                {
                    return floor
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetFloorByIDEndpoint(id)
            let dto = try await networkService.requestDecodable(endpoint, as: FloorDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let floor = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return floor
        }
    }

    func getFloors(policy: CachePolicy) async throws -> [Floor] {
        let key = CacheKey.Map.allFloors

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([FloorDTO].self, for: key) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }

            let endpoint = GetFloorsEndpoint()
            let dtos = try await networkService.requestDecodable(endpoint, as: [FloorDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }

        case .networkFirst:
            do {
                let endpoint = GetFloorsEndpoint()
                let dtos = try await networkService.requestDecodable(endpoint, as: [FloorDTO].self)
                try? await cacheStore.save(dtos, for: key)
                return dtos.compactMap { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([FloorDTO].self, for: key) {
                    return cachedDTOs.compactMap { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetFloorsEndpoint()
            let dtos = try await networkService.requestDecodable(endpoint, as: [FloorDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }
        }
    }
}
