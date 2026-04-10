import Foundation

private struct UserAchievementsResponse: Decodable {
    let userId: String
    let achievments: [AchievementDTO]
}

private struct UserLikedEventsResponse: Decodable {
    let userId: String
    let likedEvents: [EventDTO]
}

final class UsersRepository: UsersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getMyProfile(policy _: CachePolicy) async throws -> UserProfile {
        let endpoint = GetUserProfileEndpoint()
        let dto = try await networkService.requestDecodable(
            endpoint,
            as: UserProfileDTO.self
        )
        guard let profile = dto.toEntity() else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Failed to map UserProfileDTO to UserProfile")
            )
        }
        return profile
    }

    func getUserLikedEvents(userID: String, policy _: CachePolicy) async throws -> [Event] {
        let endpoint = GetUserLikedEventsEndpoint(userID)

        if let wrappedResponse = try? await networkService.requestDecodable(
            endpoint,
            as: UserLikedEventsResponse.self
        ) {
            return wrappedResponse.likedEvents.compactMap { $0.toEntity() }
        }

        let plainResponse = try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        )
        return plainResponse.compactMap { $0.toEntity() }
    }

    func getUserAchievements(userID: String, policy _: CachePolicy) async throws -> [Achievement] {
        let endpoint = GetUserAchievmentsEndpoint(userID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: UserAchievementsResponse.self
        )
        return response.achievments.map { $0.toEntity() }
    }
}

final class CachedUsersRepository: UsersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: BadgeCacheStoreProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheStore: BadgeCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getMyProfile(policy: CachePolicy) async throws -> UserProfile {
        let key = CacheKey.Badge.myProfile

        switch policy {
        case .cacheFirst:
            if let cachedDTO = try? await cacheStore.load(UserProfileDTO.self, for: key),
               let profile = cachedDTO.toEntity()
            {
                return profile
            }

            let dto = try await networkService.requestDecodable(
                GetUserProfileEndpoint(),
                as: UserProfileDTO.self
            )
            try? await cacheStore.save(dto, for: key)

            guard let profile = dto.toEntity() else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Failed to map UserProfileDTO to UserProfile")
                )
            }
            return profile

        case .networkFirst:
            do {
                let dto = try await networkService.requestDecodable(
                    GetUserProfileEndpoint(),
                    as: UserProfileDTO.self
                )
                try? await cacheStore.save(dto, for: key)

                guard let profile = dto.toEntity() else {
                    throw DecodingError.dataCorrupted(
                        .init(codingPath: [], debugDescription: "Failed to map UserProfileDTO to UserProfile")
                    )
                }
                return profile
            } catch {
                if let cachedDTO = try? await cacheStore.load(UserProfileDTO.self, for: key),
                   let profile = cachedDTO.toEntity()
                {
                    return profile
                }
                throw error
            }

        case .ignoreCache:
            let dto = try await networkService.requestDecodable(
                GetUserProfileEndpoint(),
                as: UserProfileDTO.self
            )

            try? await cacheStore.save(dto, for: key)

            guard let profile = dto.toEntity() else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Failed to map UserProfileDTO to UserProfile")
                )
            }
            return profile
        }
    }

    func getUserLikedEvents(userID: String, policy: CachePolicy) async throws -> [Event] {
        let key = CacheKey.Badge.userLikedEvents(userID: userID)

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([EventDTO].self, for: key) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }

            let dtos = try await loadLikedEventsDTOs(userID: userID)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }

        case .networkFirst:
            do {
                let dtos = try await loadLikedEventsDTOs(userID: userID)
                try? await cacheStore.save(dtos, for: key)
                return dtos.compactMap { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([EventDTO].self, for: key) {
                    return cachedDTOs.compactMap { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let dtos = try await loadLikedEventsDTOs(userID: userID)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }
        }
    }

    func getUserAchievements(userID: String, policy: CachePolicy) async throws -> [Achievement] {
        let key = CacheKey.Badge.userAchievements(userID: userID)

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([AchievementDTO].self, for: key) {
                return cachedDTOs.map { $0.toEntity() }
            }

            let dtos = try await loadUserAchievementsDTOs(userID: userID)
            try? await cacheStore.save(dtos, for: key)
            return dtos.map { $0.toEntity() }

        case .networkFirst:
            do {
                let dtos = try await loadUserAchievementsDTOs(userID: userID)
                try? await cacheStore.save(dtos, for: key)
                return dtos.map { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([AchievementDTO].self, for: key) {
                    return cachedDTOs.map { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let dtos = try await loadUserAchievementsDTOs(userID: userID)
            try? await cacheStore.save(dtos, for: key)
            return dtos.map { $0.toEntity() }
        }
    }
}

private extension CachedUsersRepository {
    func loadLikedEventsDTOs(userID: String) async throws -> [EventDTO] {
        let endpoint = GetUserLikedEventsEndpoint(userID)

        if let wrappedResponse = try? await networkService.requestDecodable(
            endpoint,
            as: UserLikedEventsResponse.self
        ) {
            return wrappedResponse.likedEvents
        }

        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        )
    }

    func loadUserAchievementsDTOs(userID: String) async throws -> [AchievementDTO] {
        let endpoint = GetUserAchievmentsEndpoint(userID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: UserAchievementsResponse.self
        )
        return response.achievments
    }
}
