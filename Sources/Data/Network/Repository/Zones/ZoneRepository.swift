final class ZoneRepository: ZoneRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getZone(zoneID: String) async throws -> Zone {
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

    func getZones(floorID: String) async throws -> [Zone] {
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

    init(networkService: NetworkServiceProtocol, cacheStore: ScheduleCacheStoreProtocol) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getZone(zoneID: String) async throws -> Zone {
        if let cachedDTO = try? await cacheStore.load(ZoneDTO.self, for: CacheKey.Schedule.zone(zoneID: zoneID)),
           let zone = cachedDTO.toEntity()
        {
            return zone
        }

        do {
            let endpoint = GetZoneByIDEndpoint(zoneID)
            let dto = try await networkService.requestDecodable(endpoint, as: ZoneDTO.self)
            try? await cacheStore.save(dto, for: CacheKey.Schedule.zone(zoneID: zoneID))
            if let zone = dto.toEntity() {
                return zone
            }
            throw NetworkError.decodingFailed
        } catch {
            if let cachedDTO = try? await cacheStore.load(ZoneDTO.self, for: CacheKey.Schedule.zone(zoneID: zoneID)),
               let zone = cachedDTO.toEntity()
            {
                return zone
            }
            throw error
        }
    }

    func getZones(floorID: String) async throws -> [Zone] {
        if let cachedDTOs = try? await cacheStore.load([ZoneDTO].self, for: CacheKey.Schedule.zones(floorID: floorID)) {
            return cachedDTOs.compactMap { $0.toEntity() }
        }

        do {
            let endpoint = GetZonesByFloorIDEndpoint(floorID)
            let dtos = try await networkService.requestDecodable(endpoint, as: [ZoneDTO].self)
            try? await cacheStore.save(dtos, for: CacheKey.Schedule.zones(floorID: floorID))
            return dtos.compactMap { $0.toEntity() }
        } catch {
            if let cachedDTOs = try? await cacheStore.load([ZoneDTO].self, for: CacheKey.Schedule.zones(floorID: floorID)) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }
            throw error
        }
    }
}
