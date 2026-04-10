//
//  AppIntent.swift
//  YoungConLiveActivity
//
//  Created by Сергей Мещеряков on 06.04.2026.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource {
        "Configuration"
    }

    static var description: IntentDescription {
        "This is an example widget."
    }

    /// An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
