import SwiftUI

enum AppTab: CaseIterable {
    case map, schedule, badge, scanner

    static let clientTabs: [AppTab] = [.map, .schedule, .badge]
    static let organizerTabs: [AppTab] = [.map, .schedule, .scanner]

    var label: String {
        switch self {
        case .map: "Карта"
        case .schedule: "Расписание"
        case .badge: "Бейдж"
        case .scanner: "Сканер"
        }
    }

    var icon: String {
        switch self {
        case .map: "map"
        case .schedule: "calendar"
        case .badge: "person.crop.circle"
        case .scanner: "qrcode.viewfinder"
        }
    }

    var index: Int {
        switch self {
        case .map: 0
        case .schedule: 1
        case .badge: 2
        case .scanner: 2
        }
    }
}
