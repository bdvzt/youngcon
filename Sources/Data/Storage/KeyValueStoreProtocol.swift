import Foundation

protocol KeyValueStoreProtocol {
    func set(_ data: Data, for key: String) throws
    func get(for key: String) throws -> Data?
    func delete(for key: String) throws
}

protocol DataCacheStoreProtocol: Sendable {
    func save(_ value: some Encodable & Sendable, for key: String) async throws
    func load<T: Decodable & Sendable>(_ type: T.Type, for key: String) async throws -> T?
}

typealias ScheduleCacheStoreProtocol = DataCacheStoreProtocol

enum CacheNamespace: String {
    case schedule
    case map
    case badge
}

enum CacheKey {
    static func make(_ namespace: CacheNamespace, _ components: String...) -> String {
        let safe = components.map { $0.replacingOccurrences(of: ".", with: "_") }
        return ([namespace.rawValue] + safe).joined(separator: ".")
    }

    enum Schedule {
        static let lastFestival = CacheKey.make(.schedule, "festival", "last")
        static let allSpeakers = CacheKey.make(.schedule, "speakers", "all")

        static func events(festivalID: String) -> String {
            CacheKey.make(.schedule, "events", "festival", festivalID)
        }

        static func event(eventID: String) -> String {
            CacheKey.make(.schedule, "event", eventID)
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
