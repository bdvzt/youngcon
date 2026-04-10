import Foundation

enum BadgeError: Error, CustomStringConvertible {
    case profileLoadingFailed(Error)
    case achievementsLoadingFailed(Error)
    case userProgressLoadingFailed(Error)

    var description: String {
        switch self {
        case let .profileLoadingFailed(error):
            "[Badge] Failed to load user profile: \(error.localizedDescription)"
        case let .achievementsLoadingFailed(error):
            "[Badge] Failed to load global achievements list: \(error.localizedDescription)"
        case let .userProgressLoadingFailed(error):
            "[Badge] Failed to load user's unlocked achievements: \(error.localizedDescription)"
        }
    }
}
