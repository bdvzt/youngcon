import Foundation

/// Корневой DI-контейнер приложения.
///
/// На этом этапе — только каркас: один экземпляр на процесс, проброс через SwiftUI `Environment`.
/// Сюда позже добавляют:
/// - `lazy` сервисы (сеть, keychain);
/// - репозитории, завязанные на протоколы из Domain;
/// - фабрики `make…ViewModel(...)` для экранов.
///
/// См. `Documentation/Architecture-MVVM-DI.md`.
final class DependencyContainer {
    // MARK: - Сервисы и репозитории (позже)

    // Пример:
    // private lazy var tokenStorage: TokenStorageProtocol = KeychainTokenStorage()
    // private lazy var networkService: NetworkServiceProtocol = NetworkService(
    //     authorizationProvider: AuthorizationProvider(tokenStorage: tokenStorage)
    // )
    // private lazy var eventsRepository: EventsRepositoryProtocol = EventsRepository(networkService: networkService)

    // MARK: - Фабрики ViewModel (позже)

    // Пример:
    // @MainActor
    // func makeScheduleViewModel() -> ScheduleViewModel {
    //     ScheduleViewModel(eventsRepository: eventsRepository)
    // }

    init() {}

    /// Продакшен: сюда подключать реальные зависимости.
    static func live() -> DependencyContainer {
        DependencyContainer()
    }

    /// Превью и тесты: моки или облегчённый контейнер.
    static var preview: DependencyContainer {
        DependencyContainer()
    }
}
