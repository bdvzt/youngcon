import Foundation

enum ScheduleFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case favorites = "Избранное"
    case live = "Live"
    case lecture = "Лекция"
    case interactive = "Интерактив"
    case backend = "Backend"
    case ml = "ML"

    var id: String {
        rawValue
    }

    func matches(_ entry: ScheduleEntry) -> Bool {
        switch self {
        case .all:
            true
        case .favorites:
            false
        case .live:
            entry.streamURL != nil
        case .lecture, .interactive, .backend, .ml:
            entry.event.category.lowercased() == rawValue.lowercased()
        }
    }
}
