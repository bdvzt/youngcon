import Foundation

extension DependencyContainer {
    @MainActor
    func makeScheduleViewModel() -> ScheduleViewModel {
        ScheduleViewModel(
            festivalsRepository: festivalsRepository,
            eventsRepository: eventsRepository,
            zoneRepository: zoneRepository
        )
    }
}
