import Foundation

protocol DataCacheStoreProtocol: Sendable {
    func save(_ value: some Encodable & Sendable, for key: String) async throws
    func load<T: Decodable & Sendable>(_ type: T.Type, for key: String) async throws -> T?
}

typealias ScheduleCacheStoreProtocol = DataCacheStoreProtocol
