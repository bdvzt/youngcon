import Foundation

struct UserState: Decodable {
    let profile: UserProfile
    let unlockedAchievementIDs: Set<UUID>
    let favoriteEventIDs: Set<UUID>
}
