//
//  UserState.swift
//  YoungCon
//
//  Created by Сергей Мещеряков on 02.04.2026.
//

import Foundation

struct UserState: Codable {
    let profile: UserProfile
    let unlockedAchievementIDs: Set<UUID>
    let favoriteEventIDs: Set<UUID>
}
