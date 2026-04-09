import SwiftUI

/// Mirrors `AppColor` / asset catalog values so the extension does not depend on the app target or Tuist `YoungConAsset`.
enum LiveActivityTheme {
    static let appBackground = Color(red: 10 / 255, green: 11 / 255, blue: 19 / 255)
    static let cardBackground = Color(red: 21 / 255, green: 22 / 255, blue: 33 / 255)
    static let accentYellow = Color(red: 252 / 255, green: 255 / 255, blue: 114 / 255)
    static let accentPurple = Color(red: 197 / 255, green: 158 / 255, blue: 255 / 255)
    /// Same as `AppColor.liveRed` (schedule “идёт эфир” dot).
    static let liveRed = Color(red: 0.99, green: 0.25, blue: 0.11)
    static let gray500 = Color(red: 107 / 255, green: 114 / 255, blue: 128 / 255)

    static let accentGradient = LinearGradient(
        colors: [accentYellow, accentPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
}
