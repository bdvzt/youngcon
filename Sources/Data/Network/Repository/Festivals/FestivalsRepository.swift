final class FestivalsRepository: FestivalsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getLastFestival(policy _: CachePolicy) async throws -> Festival {
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

    init(
        networkService: NetworkServiceProtocol,
        cacheStore: ScheduleCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getLastFestival(policy: CachePolicy) async throws -> Festival {
        let key = CacheKey.Schedule.lastFestival

        switch policy {
        case .cacheFirst:
            if let cachedDTO = try? await cacheStore.load(FestivalDTO.self, for: key),
               let cachedFestival = cachedDTO.toEntity()
            {
                return cachedFestival
            }

            let dto = try await networkService.requestDecodable(
                GetLastFestivalEndpoint(),
                as: FestivalDTO.self
            )
            try? await cacheStore.save(dto, for: key)

            guard let festival = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return festival

        case .networkFirst:
            do {
                let dto = try await networkService.requestDecodable(
                    GetLastFestivalEndpoint(),
                    as: FestivalDTO.self
                )
                try? await cacheStore.save(dto, for: key)

                guard let festival = dto.toEntity() else {
                    throw NetworkError.decodingFailed
                }
                return festival
            } catch {
                if let cachedDTO = try? await cacheStore.load(FestivalDTO.self, for: key),
                   let cachedFestival = cachedDTO.toEntity()
                {
                    return cachedFestival
                }
                throw error
            }

        case .ignoreCache:
            let dto = try await networkService.requestDecodable(
                GetLastFestivalEndpoint(),
                as: FestivalDTO.self
            )
            try? await cacheStore.save(dto, for: key)

            guard let festival = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return festival
        }
    }
}
