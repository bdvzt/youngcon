import Foundation

final class DependencyContainer {
    private lazy var tokenStorage: TokenStorageProtocol = KeychainTokenStorage()

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

    private(set) lazy var eventsRepository: EventsRepositoryProtocol = EventsRepository(
        networkService: networkService
    )

    private(set) lazy var festivalsRepository: FestivalsRepositoryProtocol = FestivalsRepository(
        networkService: networkService
    )

    private(set) lazy var floorsRepository: FloorsRepositoryProtocol = FloorsRepository(
        networkService: networkService
    )

    private(set) lazy var speakersRepository: SpeakersRepositoryProtocol = SpeakersRepository(
        networkService: networkService
    )

    private(set) lazy var usersRepository: UsersRepositoryProtocol = UsersRepository(
        networkService: networkService
    )

    private(set) lazy var zoneRepository: ZoneRepositoryProtocol = ZoneRepository(
        networkService: networkService
    )

    init() {}

    static func live() -> DependencyContainer {
        DependencyContainer()
    }

    static var preview: DependencyContainer {
        DependencyContainer()
    }
}
