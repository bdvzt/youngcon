final class EventsRepository: EventsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getEvents(
        festivalID: String,
        policy _: CachePolicy
    ) async throws -> [Event] {
        let endpoint = GetEventsEndpoint(festivalID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func getEvent(
        eventID: String,
        policy _: CachePolicy
    ) async throws -> Event {
        let endpoint = GetEventByIDEndpoint(eventID)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: EventDTO.self
        )
        guard let event = response.toEntity() else {
            throw NetworkError.decodingFailed
        }
        return event
    }

    func getZoneEvents(zoneID: String) async throws -> [Event] {
        let endpoint = GetZoneEventsEndpoint(zoneID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func getSpeakerEvents(speakerID: String) async throws -> [Event] {
        let endpoint = GetSpeakerEventsEndpoint(speakerID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func likeEvent(eventID: String) async throws -> LikeEventResponse {
        let endpoint = LikeEventEndpoint(eventID)
        return try await networkService.requestDecodable(
            endpoint,
            as: LikeEventResponse.self
        )
    }
}

final class CachedEventsRepository: EventsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let baseRepository: EventsRepositoryProtocol
    private let cacheStore: ScheduleCacheStoreProtocol

    init(
        networkService: NetworkServiceProtocol,
        baseRepository: EventsRepositoryProtocol,
        cacheStore: ScheduleCacheStoreProtocol
    ) {
        self.networkService = networkService
        self.baseRepository = baseRepository
        self.cacheStore = cacheStore
    }

    func getEvents(
        festivalID: String,
        policy: CachePolicy
    ) async throws -> [Event] {
        let key = CacheKey.Schedule.events(festivalID: festivalID)

        switch policy {
        case .cacheFirst:
            if let cachedDTOs = try? await cacheStore.load([EventDTO].self, for: key) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }

            let endpoint = GetEventsEndpoint(festivalID)
            let dtos = try await networkService.requestDecodable(endpoint, as: [EventDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }

        case .networkFirst:
            do {
                let endpoint = GetEventsEndpoint(festivalID)
                let dtos = try await networkService.requestDecodable(endpoint, as: [EventDTO].self)
                try? await cacheStore.save(dtos, for: key)
                return dtos.compactMap { $0.toEntity() }
            } catch {
                if let cachedDTOs = try? await cacheStore.load([EventDTO].self, for: key) {
                    return cachedDTOs.compactMap { $0.toEntity() }
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetEventsEndpoint(festivalID)
            let dtos = try await networkService.requestDecodable(endpoint, as: [EventDTO].self)
            try? await cacheStore.save(dtos, for: key)
            return dtos.compactMap { $0.toEntity() }
        }
    }

    func getEvent(
        eventID: String,
        policy: CachePolicy
    ) async throws -> Event {
        let key = CacheKey.Schedule.event(eventID: eventID)

        switch policy {
        case .cacheFirst:
            if let cachedDTO = try? await cacheStore.load(EventDTO.self, for: key),
               let event = cachedDTO.toEntity()
            {
                return event
            }

            let endpoint = GetEventByIDEndpoint(eventID)
            let dto = try await networkService.requestDecodable(endpoint, as: EventDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let event = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return event

        case .networkFirst:
            do {
                let endpoint = GetEventByIDEndpoint(eventID)
                let dto = try await networkService.requestDecodable(endpoint, as: EventDTO.self)
                try? await cacheStore.save(dto, for: key)

                guard let event = dto.toEntity() else {
                    throw NetworkError.decodingFailed
                }
                return event
            } catch {
                if let cachedDTO = try? await cacheStore.load(EventDTO.self, for: key),
                   let event = cachedDTO.toEntity()
                {
                    return event
                }
                throw error
            }

        case .ignoreCache:
            let endpoint = GetEventByIDEndpoint(eventID)
            let dto = try await networkService.requestDecodable(endpoint, as: EventDTO.self)
            try? await cacheStore.save(dto, for: key)

            guard let event = dto.toEntity() else {
                throw NetworkError.decodingFailed
            }
            return event
        }
    }

    func getZoneEvents(zoneID: String) async throws -> [Event] {
        let endpoint = GetZoneEventsEndpoint(zoneID)
        return try await networkService.requestDecodable(
            endpoint,
            as: [EventDTO].self
        ).compactMap { $0.toEntity() }
    }

    func getSpeakerEvents(speakerID: String) async throws -> [Event] {
        if let cachedDTOs = try? await cacheStore.load(
            [EventDTO].self,
            for: CacheKey.Schedule.speakerEvents(speakerID: speakerID)
        ) {
            return cachedDTOs.compactMap { $0.toEntity() }
        }

        do {
            let endpoint = GetSpeakerEventsEndpoint(speakerID)
            let dtos = try await networkService.requestDecodable(endpoint, as: [EventDTO].self)
            try? await cacheStore.save(
                dtos,
                for: CacheKey.Schedule.speakerEvents(speakerID: speakerID)
            )
            return dtos.compactMap { $0.toEntity() }
        } catch {
            if let cachedDTOs = try? await cacheStore.load(
                [EventDTO].self,
                for: CacheKey.Schedule.speakerEvents(speakerID: speakerID)
            ) {
                return cachedDTOs.compactMap { $0.toEntity() }
            }
            throw error
        }
    }

    func likeEvent(eventID: String) async throws -> LikeEventResponse {
        try await baseRepository.likeEvent(eventID: eventID)
    }
}
