//
//  AppTab.swift
//  app
//
//  Created by m.yaganova on 02.04.2026.
//

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
        case .map:      return Color(hex: "#C59EFF")
        case .schedule: return Color(hex: "#FCFF72")
        case .badge:    return Color(hex: "#FF87BB")
        }
    }
}
