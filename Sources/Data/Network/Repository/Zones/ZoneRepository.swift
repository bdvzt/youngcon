final class ZoneRepository: ZoneRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getZone(zoneID: String, policy _: CachePolicy) async throws -> Zone {
        let endpoint = GetZoneByIDEndpoint(zoneID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: ZoneDTO.self
        )
        guard let zone = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return zone
    }

    func getZones(floorID: String, policy _: CachePolicy) async throws -> [Zone] {
        let endpoint = GetZonesByFloorIDEndpoint(floorID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [ZoneDTO].self
        ).compactMap { $0.toEntity() }
    }
}

final class CachedZoneRepository: ZoneRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: ScheduleCacheStoreProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheStore: ScheduleCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getZone(zoneID: String, policy: CachePolicy) async throws -> Zone {
        let key = CacheKey.Schedule.zone(zoneID: zoneID)

        switch policy {
        case .cacheFirst:
            if let cachedDTO = try? await cacheStore.load(ZoneDTO.self, for: key),
               let zone = cachedDTO.toEntity()
            {
                return zone
            }

            let endpoint = GetZoneByIDEndpoint(zoneID)
            let dto = try await networkService.requestDecodable(endpoint, as: ZoneDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let zone = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return zone

        case .networkFirst:
            do {
                let endpoint = GetZoneByIDEndpoint(zoneID)
                let dto = try await networkService.requestDecodable(endpoint, as: ZoneDTO.self)
                try? await cacheStore.save(dto, for: key)

                guard let zone = dto.toEntity() else {
                    throw NetworkError.decodingFailed
                }
                return zone
            } catch {
                if let cachedDTO = try? await cacheStore.load(ZoneDTO.self, for: key),
                   let zone = cachedDTO.toEntity()
                {
                    return zone
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetZoneByIDEndpoint(zoneID)
            let dto = try await networkService.requestDecodable(endpoint, as: ZoneDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let zone = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return zone
        }
    }

    func getZones(floorID: String, policy: CachePolicy) async throws -> [Zone] {
        let key = CacheKey.Schedule.zones(floorID: floorID)

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([ZoneDTO].self, for: key) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }

            let endpoint = GetZonesByFloorIDEndpoint(floorID)
            let dtos = try await networkService.requestDecodable(endpoint, as: [ZoneDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }

        case .networkFirst:
            do {
                let endpoint = GetZonesByFloorIDEndpoint(floorID)
                let dtos = try await networkService.requestDecodable(endpoint, as: [ZoneDTO].self)
                try? await cacheStore.save(dtos, for: key)
                return dtos.compactMap { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([ZoneDTO].self, for: key) {
                    return cachedDTOs.compactMap { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetZonesByFloorIDEndpoint(floorID)
            let dtos = try await networkService.requestDecodable(endpoint, as: [ZoneDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }
        }
    }
}
