final class FestivalsRepository: FestivalsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getLastFestival() async throws -> Festival {
        let endpoint = GetLastFestivalEndpoint()
        let response = try await networkService.requestDecodable(
            endpoint,
            as: FestivalDTO.self
        )
        guard let festival = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return festival
    }
}

final class CachedFestivalsRepository: FestivalsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: ScheduleCacheStoreProtocol

    init(networkService: NetworkServiceProtocol, cacheStore: ScheduleCacheStoreProtocol) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getLastFestival() async throws -> Festival {
        if let cachedDTO = try? await cacheStore.load(FestivalDTO.self, for: CacheKey.Schedule.lastFestival),
           let cachedFestival = cachedDTO.toEntity()
        {
            return cachedFestival
        }

        do {
            let dto = try await networkService.requestDecodable(GetLastFestivalEndpoint(), as: FestivalDTO.self)
            try? await cacheStore.save(dto, for: CacheKey.Schedule.lastFestival)
            if let festival = dto.toEntity() {
                return festival
            }
            throw NetworkError.decodingFailed
        } catch {
            if let cachedDTO = try? await cacheStore.load(FestivalDTO.self, for: CacheKey.Schedule.lastFestival),
               let cachedFestival = cachedDTO.toEntity()
            {
                return cachedFestival
            }
            throw error
        }
    }
}
