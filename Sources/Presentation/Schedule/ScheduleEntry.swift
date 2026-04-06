import Foundation

struct ScheduleEntry: Identifiable {
    let id: String
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]
    let streamURL: URL?
}
