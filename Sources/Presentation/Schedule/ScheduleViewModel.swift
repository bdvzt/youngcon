import Combine
import Foundation

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var screenTitle: String = "Расписание"

    // TODO: зависимости — EventsRepositoryProtocol, FestivalRepository, кэш зон/спикеров
    // TODO: @Published events, selectedFilter, loadState, ошибки

    init() {}

    func onAppear() async {
        // TODO: загрузить текущий фестиваль → события (GET /api/events/by-festival/{id})
    }
}
