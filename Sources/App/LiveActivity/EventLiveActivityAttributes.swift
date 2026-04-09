import ActivityKit
import Foundation

/// Shared between the app (start/update/end) and `YoungConLiveActivityExtension` (UI).
/// Keep fields `Codable`-friendly; avoid app-only types here.
struct EventLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var title: String
        var startDate: Date
        var endDate: Date
        /// Zone / venue title shown in the schedule cards.
        var locationTitle: String
        /// Primary speaker / host display name (empty if unknown).
        var hostLine: String
    }

    /// Stable id for the festival session (matches `Event.id`).
    var eventID: String
}
