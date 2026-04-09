import Foundation

final class AchievementsRepository: AchievementsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getAchievements(policy _: CachePolicy) async throws -> [Achievement] {
        let endpoint = GetAchievmentsEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [AchievementDTO].self
        ).compactMap { $0.toEntity() }
    }
}

final class CachedAchievementsRepository: AchievementsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: BadgeCacheStoreProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheStore: BadgeCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getAchievements(policy: CachePolicy) async throws -> [Achievement] {
        let key = CacheKey.Badge.allAchievements

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([AchievementDTO].self, for: key) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }

            let dtos = try await networkService.requestDecodable(
                GetAchievmentsEndpoint(),
                as: [AchievementDTO].self
            )
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }

        case .networkFirst:
            do {
                let dtos = try await networkService.requestDecodable(
                    GetAchievmentsEndpoint(),
                    as: [AchievementDTO].self
                )
                try? await cacheStore.save(dtos, for: key)
                return dtos.compactMap { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([AchievementDTO].self, for: key) {
                    return cachedDTOs.compactMap { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let dtos = try await networkService.requestDecodable(
                GetAchievmentsEndpoint(),
                as: [AchievementDTO].self
            )
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }
        }
    }
}
