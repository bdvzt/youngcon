import SwiftUI

enum AppTab: CaseIterable {
    case map, schedule, badge

    var label: String {
        switch self {
        case .map:      return "Карта"
        case .schedule: return "Расписание"
        case .badge:    return "Бейдж"
        }
    }

    var icon: String {
        switch self {
        case .map:      return "map"
        case .schedule: return "calendar"
        case .badge:    return "person.crop.circle"
        }
    }

    var pageColor: Color {
        switch self {
        case .map:      return Color("TabMapColor")
        case .schedule: return Color("TabScheduleColor")
        case .badge:    return Color("TabBadgeColor")
        }
    }
}
