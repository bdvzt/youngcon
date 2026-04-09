final class SpeakersRepository: SpeakersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getSpeaker(speakerID: String) async throws -> Speaker {
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

    func getAllSpeakers() async throws -> [Speaker] {
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

    init(networkService: NetworkServiceProtocol, cacheStore: ScheduleCacheStoreProtocol) {
        self.networkService = networkService
        self.cacheStore = cacheStore
    }

    func getSpeaker(speakerID: String) async throws -> Speaker {
        do {
            let endpoint = GetSpeakerByIDEndpoint(speakerID)
            let dto = try await networkService.requestDecodable(endpoint, as: SpeakerDTO.self)
            try? await cacheStore.save(dto, for: CacheKey.Schedule.speaker(speakerID: speakerID))
            if let speaker = dto.toEntity() {
                return speaker
            }
            throw NetworkError.decodingFailed
        } catch {
            if let cachedDTO = try? await cacheStore.load(SpeakerDTO.self, for: CacheKey.Schedule.speaker(speakerID: speakerID)),
               let speaker = cachedDTO.toEntity()
            {
                return speaker
            }
            throw error
        }
    }

    func getAllSpeakers() async throws -> [Speaker] {
        do {
            let endpoint = GetSpeakersEndpoint()
            let dtos = try await networkService.requestDecodable(endpoint, as: [SpeakerDTO].self)
            try? await cacheStore.save(dtos, for: CacheKey.Schedule.allSpeakers)
            return dtos.compactMap { $0.toEntity() }
        } catch {
            if let cachedDTOs = try? await cacheStore.load([SpeakerDTO].self, for: CacheKey.Schedule.allSpeakers) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }
            throw error
        }
    }
}
