import Foundation

final class DependencyContainer {
    let authRepository: AuthRepositoryProtocol
    let achievementsRepository: AchievementsRepositoryProtocol
    let eventsRepository: EventsRepositoryProtocol
    let festivalsRepository: FestivalsRepositoryProtocol
    let floorsRepository: FloorsRepositoryProtocol
    let speakersRepository: SpeakersRepositoryProtocol
    let usersRepository: UsersRepositoryProtocol
    let zoneRepository: ZoneRepositoryProtocol

    private init(
        authRepository: AuthRepositoryProtocol,
        achievementsRepository: AchievementsRepositoryProtocol,
        eventsRepository: EventsRepositoryProtocol,
        festivalsRepository: FestivalsRepositoryProtocol,
        floorsRepository: FloorsRepositoryProtocol,
        speakersRepository: SpeakersRepositoryProtocol,
        usersRepository: UsersRepositoryProtocol,
        zoneRepository: ZoneRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.achievementsRepository = achievementsRepository
        self.eventsRepository = eventsRepository
        self.festivalsRepository = festivalsRepository
        self.floorsRepository = floorsRepository
        self.speakersRepository = speakersRepository
        self.usersRepository = usersRepository
        self.zoneRepository = zoneRepository
    }

    static func live() -> DependencyContainer {
        let tokenStorage: TokenStorageProtocol = KeychainTokenStorage()
        let networkService: NetworkServiceProtocol = NetworkService(
            authorizationProvider: AuthorizationProvider(tokenStorage: tokenStorage),
            tokenStorage: tokenStorage
        )

        return DependencyContainer(
            authRepository: AuthRepository(
                networkService: networkService,
                tokenStorage: tokenStorage
            ),
            achievementsRepository: AchievementsRepository(
                networkService: networkService
            ),
            eventsRepository: EventsRepository(
                networkService: networkService
            ),
            festivalsRepository: FestivalsRepository(
                networkService: networkService
            ),
            floorsRepository: FloorsRepository(
                networkService: networkService
            ),
            speakersRepository: SpeakersRepository(
                networkService: networkService
            ),
            usersRepository: UsersRepository(
                networkService: networkService
            ),
            zoneRepository: ZoneRepository(
                networkService: networkService
            )
        )
    }

    /// SwiftUI Preview / Debug without backend: in-memory data, no `NetworkService`.
    static var preview: DependencyContainer {
        let store = SchedulePreviewFixtures.makeStore(referenceDate: Date())
        return DependencyContainer(
            authRepository: PreviewAuthRepository(),
            achievementsRepository: PreviewAchievementsRepository(),
            eventsRepository: PreviewEventsRepository(store: store),
            festivalsRepository: PreviewFestivalsRepository(store: store),
            floorsRepository: PreviewFloorsRepository(),
            speakersRepository: PreviewSpeakersRepository(store: store),
            usersRepository: PreviewUsersRepository(),
            zoneRepository: PreviewZoneRepository(store: store)
        )
    }

    /// Chooses container for a normal app launch (not SwiftUI Preview).
    ///
    /// **Release:** always real network (`live()`).
    ///
    /// **Debug + Simulator:** in-memory **`preview`** by default (no backend, no launch flags needed). To hit the real API from the simulator, add **`-UseLiveAPI`** or environment **`USE_LIVE_API = 1`**.
    ///
    /// **Debug + physical device:** **`live()`** by default. For mocks, pass **`-UsePreviewMocks`** or set **`USE_PREVIEW_MOCKS = 1`** in the scheme environment.
    static func makeForAppLaunch() -> DependencyContainer {
        #if !DEBUG
            return live()
        #else
            let args = ProcessInfo.processInfo.arguments
            let env = ProcessInfo.processInfo.environment

            func envIsTruthy(_ key: String) -> Bool {
                guard let raw = env[key]?.lowercased() else { return false }
                return raw == "1" || raw == "yes" || raw == "true"
            }

            let useLiveAPI =
                args.contains("-UseLiveAPI")
                    || envIsTruthy("USE_LIVE_API")

            if useLiveAPI {
                return live()
            }

            #if targetEnvironment(simulator)
                // Simulator Debug: mocks unless explicitly `-UseLiveAPI` / `USE_LIVE_API`.
                return preview
            #else
                let usePreviewMocks =
                    args.contains("-UsePreviewMocks")
                        || envIsTruthy("USE_PREVIEW_MOCKS")
                if usePreviewMocks {
                    return preview
                }
                return live()
            #endif
        #endif
    }
}
