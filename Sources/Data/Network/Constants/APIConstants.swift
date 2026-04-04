import Foundation

enum APIConstants {
    // swiftlint:disable:next force_unwrapping
    static let baseURL = URL(string: "http://213.165.218.183:8080/api/")!

    enum Auth {
        static let login = "auth/login"
        static let logout = "auth/logout"
    }

    enum Achievements {
        static let list = "achievements"
        static func details(_ id: String) -> String {
            "achievements/\(id)"
        }
    }

    enum Events {
        static func byFestival(_ festivalID: String) -> String {
            "events/by-festival/\(festivalID)"
        }

        static func details(_ id: String) -> String {
            "events/\(id)"
        }

        static func speakers(_ id: String) -> String {
            "events/\(id)/speakers"
        }

        static func byZone(_ zoneID: String) -> String {
            "events/by-zone/\(zoneID)"
        }

        static func bySpeaker(_ speakerID: String) -> String {
            "events/by-speaker/\(speakerID)"
        }

        static func like(_ id: String) -> String {
            "events/\(id)/like"
        }
    }

    enum Festivals {
        static let list = "festivals"
        static let last = "festivals/last"
        static func details(_ id: String) -> String {
            "festivals/\(id)"
        }
    }

    enum Floors {
        static let list = "floors"
        static func details(_ id: String) -> String {
            "floors/\(id)"
        }
    }

    enum Speakers {
        static let list = "speakers"
        static func details(_ id: String) -> String {
            "speakers/\(id)"
        }
    }

    enum Users {
        static let resolveQR = "users/qr/resolve"
        static let assignAchievementByQR = "users/achievements/assign-by-qr"
        static let profile = "users/myself"
        static let myQR = "users/myself/qr"
        static func achievements(_ id: String) -> String {
            "users/\(id)/achievements"
        }

        static func likedEvents(_ id: String) -> String {
            "users/\(id)/liked-events"
        }
    }

    enum Zones {
        static let list = "zones"
        static func details(_ id: String) -> String {
            "zones/\(id)"
        }

        static func byFloor(_ floorID: String) -> String {
            "zones/by-floor/\(floorID)"
        }
    }
}
