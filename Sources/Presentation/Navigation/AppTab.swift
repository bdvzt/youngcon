import SwiftUI

enum AppTab: CaseIterable {
    case map, schedule, badge
    
    var index: Int {
           switch self {
           case .map:      0
           case .schedule: 1
           case .badge:    2
           }
       }
    
    var label: String {
            switch self {
            case .map:
                "Карта"
            case .schedule:
                "Расписание"
            case .badge:
                "Бейдж"
            }
        }
    
    var icon: String {
        switch self {
        case .map:
            "map"
        case .schedule:
            "calendar"
        case .badge:
            "person.crop.circle"
        }
    }

    var pageColor: Color {
        switch self {
        case .map:
            Color("TabMapColor")
        case .schedule:
            Color("TabScheduleColor")
        case .badge:
            Color("TabBadgeColor")
        }
    }
}
