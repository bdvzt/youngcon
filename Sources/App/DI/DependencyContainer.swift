import Foundation

final class DependencyContainer {
    private lazy var tokenStorage: TokenStorageProtocol = KeychainTokenStorage()
    private lazy var scheduleCacheStore: ScheduleCacheStoreProtocol = CoreDataScheduleCacheStore()

    private lazy var networkService: NetworkServiceProtocol = NetworkService(
        authorizationProvider: AuthorizationProvider(tokenStorage: tokenStorage),
        tokenStorage: tokenStorage
    )

    private(set) lazy var authRepository: AuthRepositoryProtocol = AuthRepository(
        networkService: networkService,
        tokenStorage: tokenStorage
    )

    private(set) lazy var achievementsRepository: AchievementsRepositoryProtocol = AchievementsRepository(
        networkService: networkService
    )

    private(set) lazy var organizerRepository: OrganizerRepositoryProtocol = OrganizerRepository(
        networkService: networkService,
        tokenStorage: tokenStorage
    )

    private lazy var networkEventsRepository: EventsRepositoryProtocol = EventsRepository(
        networkService: networkService
    )

    private(set) lazy var eventsRepository: EventsRepositoryProtocol = CachedEventsRepository(
        networkService: networkService,
        baseRepository: networkEventsRepository,
        cacheStore: scheduleCacheStore
    )

    private(set) lazy var festivalsRepository: FestivalsRepositoryProtocol = CachedFestivalsRepository(
        networkService: networkService,
        cacheStore: scheduleCacheStore
    )

    private(set) lazy var floorsRepository: FloorsRepositoryProtocol = CachedFloorsRepository(
        networkService: networkService,
        cacheStore: scheduleCacheStore
    )

    private(set) lazy var speakersRepository: SpeakersRepositoryProtocol = CachedSpeakersRepository(
        networkService: networkService,
        cacheStore: scheduleCacheStore
    )

    private(set) lazy var usersRepository: UsersRepositoryProtocol = UsersRepository(
        networkService: networkService
    )

    private(set) lazy var zoneRepository: ZoneRepositoryProtocol = CachedZoneRepository(
        networkService: networkService,
        cacheStore: scheduleCacheStore
    )

    init() {}

    static func live() -> DependencyContainer {
        DependencyContainer()
    }

    static var preview: DependencyContainer {
        DependencyContainer()
    }
}
