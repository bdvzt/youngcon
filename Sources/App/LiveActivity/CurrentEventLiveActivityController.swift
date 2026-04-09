import ActivityKit
import Foundation

/// Keeps the Live Activity in sync with the event that is **currently in progress** according to the schedule.
@available(iOS 16.1, *)
enum CurrentEventLiveActivityController {
    static func sync(with entries: [ScheduleEntry], now: Date = .now) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // If several events overlap, we follow schedule order (same as the list in the app).
        let current = entries.first { entry in
            now >= entry.event.startDate && now <= entry.event.endDate
        }

        let activities = Activity<EventLiveActivityAttributes>.activities

        if let current {
            let rawLocation = current.zone?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let location = rawLocation.isEmpty ? "Площадка уточняется" : rawLocation

            let host =
                current.speakers.first?.fullName.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            let state = EventLiveActivityAttributes.ContentState(
                title: current.event.title,
                startDate: current.event.startDate,
                endDate: current.event.endDate,
                locationTitle: location,
                hostLine: host
            )

            let stale = current.event.endDate.addingTimeInterval(120)

            if let existing = activities.first(where: { $0.attributes.eventID == current.id }) {
                await existing.update(ActivityContent(state: state, staleDate: stale))
            } else {
                for activity in activities {
                    await activity.end(dismissalPolicy: .immediate)
                }
                let attributes = EventLiveActivityAttributes(eventID: current.id)
                let content = ActivityContent(state: state, staleDate: stale)
                _ = try? Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
            }
        } else {
            for activity in activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
