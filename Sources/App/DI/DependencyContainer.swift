import Foundation

/// Корневой контейнер: репозитории и фабрики ViewModel.
/// Cюда добавляют `lazy` репозитории, затем пробрасывают их в `make…ViewModel`.
final class DependencyContainer {
    // MARK: - Репозитории (по мере появления)

    // private lazy var eventsRepository: EventsRepositoryProtocol = EventsRepository(network: networkService)
    // private lazy var networkService: NetworkServiceProtocol = ...

    // MARK: - Инициализация

    init() {}

    /// Продакшен-контейнер: сюда позже добавить реальные сервисы и keychain.
    static func live() -> DependencyContainer {
        DependencyContainer()
    }

    /// Превью и тесты — без сети или с моками.
    static var preview: DependencyContainer {
        DependencyContainer()
    }

    // MARK: - Фабрики экранов (MainActor — создание VM для SwiftUI)

    @MainActor
    func makeScheduleViewModel() -> ScheduleViewModel {
        ScheduleViewModel()
    }

    @MainActor
    func makeMapViewModel() -> MapViewModel {
        MapViewModel()
    }

    @MainActor
    func makeBadgeViewModel() -> BadgeViewModel {
        BadgeViewModel()
    }
}
