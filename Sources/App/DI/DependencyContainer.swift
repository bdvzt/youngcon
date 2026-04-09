import Foundation

final class DependencyContainer {
    private lazy var tokenStorage: TokenStorageProtocol = KeychainTokenStorage()
    private lazy var scheduleCacheStore: ScheduleCacheStoreProtocol = CoreDataScheduleCacheStore()
    private lazy var mapCacheStore: MapCacheStoreProtocol = CoreDataMapCacheStore()
    private lazy var badgeCacheStore: BadgeCacheStoreProtocol = CoreDataBadgeCacheStore()

    private lazy var networkService: NetworkServiceProtocol = NetworkService(
        authorizationProvider: AuthorizationProvider(tokenStorage: tokenStorage),
        tokenStorage: tokenStorage
    )

    private(set) lazy var authRepository: AuthRepositoryProtocol = AuthRepository(
        networkService: networkService,
        tokenStorage: tokenStorage
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
        cacheStore: mapCacheStore
    )

    private(set) lazy var speakersRepository: SpeakersRepositoryProtocol = CachedSpeakersRepository(
        networkService: networkService,
        cacheStore: scheduleCacheStore
    )

    private(set) lazy var achievementsRepository: AchievementsRepositoryProtocol = CachedAchievementsRepository(
        networkService: networkService,
        cacheStore: badgeCacheStore
    )

    private(set) lazy var usersRepository: UsersRepositoryProtocol = CachedUsersRepository(
        networkService: networkService,
        cacheStore: badgeCacheStore
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

    /// Keep app bootstrap API stable (`YoungConApp` expects this).
    /// LiveActivity branch runs against real/cached stack from `develop`, without preview mocks.
    static func makeForAppLaunch() -> DependencyContainer {
        live()
    }
}
