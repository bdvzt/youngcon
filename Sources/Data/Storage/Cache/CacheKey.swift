import Foundation

enum CacheKey {
    static func make(_ namespace: CacheNamespace, _ components: String...) -> String {
        let safe = components.map { $0.replacingOccurrences(of: ".", with: "_") }
        return ([namespace.rawValue] + safe).joined(separator: ".")
    }

    enum Schedule {
        static let allFloors = CacheKey.make(.schedule, "floors", "all")
        static let lastFestival = CacheKey.make(.schedule, "festival", "last")
        static let allSpeakers = CacheKey.make(.schedule, "speakers", "all")

        static func events(festivalID: String) -> String {
            CacheKey.make(.schedule, "events", "festival", festivalID)
        }

        static func event(eventID: String) -> String {
            CacheKey.make(.schedule, "event", eventID)
        }

        static func floor(floorID: String) -> String {
            CacheKey.make(.schedule, "floor", floorID)
        }

        static func speaker(speakerID: String) -> String {
            CacheKey.make(.schedule, "speaker", speakerID)
        }

        static func speakerEvents(speakerID: String) -> String {
            CacheKey.make(.schedule, "events", "speaker", speakerID)
        }

        static func zone(zoneID: String) -> String {
            CacheKey.make(.schedule, "zone", zoneID)
        }

        static func zones(floorID: String) -> String {
            CacheKey.make(.schedule, "zones", "floor", floorID)
        }
    }
}
