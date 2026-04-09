final class SpeakersRepository: SpeakersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSpeaker(speakerID: String, policy _: CachePolicy) async throws -> Speaker {
        let endpoint = GetSpeakerByIDEndpoint(speakerID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: SpeakerDTO.self
        )
        guard let speaker = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return speaker
    }

    func getAllSpeakers(policy _: CachePolicy) async throws -> [Speaker] {
        let endpoint = GetSpeakersEndpoint()
        return try await networkService.requestDecodable(
            endpoint,
            as: [SpeakerDTO].self
        ).compactMap { $0.toEntity() }
    }
}

final class CachedSpeakersRepository: SpeakersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheStore: ScheduleCacheStoreProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheStore: ScheduleCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getSpeaker(speakerID: String, policy: CachePolicy) async throws -> Speaker {
        let key = CacheKey.Schedule.speaker(speakerID: speakerID)

        switch policy {
        case .cacheFirst:
            if let cachedDTO = try? await cacheStore.load(SpeakerDTO.self, for: key),
               let speaker = cachedDTO.toEntity()
            {
                return speaker
            }

            let endpoint = GetSpeakerByIDEndpoint(speakerID)
            let dto = try await networkService.requestDecodable(endpoint, as: SpeakerDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let speaker = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return speaker

        case .networkFirst:
            do {
                let endpoint = GetSpeakerByIDEndpoint(speakerID)
                let dto = try await networkService.requestDecodable(endpoint, as: SpeakerDTO.self)
                try? await cacheStore.save(dto, for: key)

                guard let speaker = dto.toEntity() else {
                    throw NetworkError.decodingFailed
                }
                return speaker
            } catch {
                if let cachedDTO = try? await cacheStore.load(SpeakerDTO.self, for: key),
                   let speaker = cachedDTO.toEntity()
                {
                    return speaker
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetSpeakerByIDEndpoint(speakerID)
            let dto = try await networkService.requestDecodable(endpoint, as: SpeakerDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let speaker = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return speaker
        }
    }

    func getAllSpeakers(policy: CachePolicy) async throws -> [Speaker] {
        let key = CacheKey.Schedule.allSpeakers

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([SpeakerDTO].self, for: key) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }

            let endpoint = GetSpeakersEndpoint()
            let dtos = try await networkService.requestDecodable(endpoint, as: [SpeakerDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }

        case .networkFirst:
            do {
                let endpoint = GetSpeakersEndpoint()
                let dtos = try await networkService.requestDecodable(endpoint, as: [SpeakerDTO].self)
                try? await cacheStore.save(dtos, for: key)
                return dtos.compactMap { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([SpeakerDTO].self, for: key) {
                    return cachedDTOs.compactMap { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetSpeakersEndpoint()
            let dtos = try await networkService.requestDecodable(endpoint, as: [SpeakerDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }
        }
    }
}
