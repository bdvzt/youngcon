import Foundation

protocol KeyValueStoreProtocol {
    func set(_ data: Data, for key: String) throws
    func set<T: Codable>(_ value: T, for key: String) throws

    func get(for key: String) throws -> Data?
    func get<T: Codable>(for key: String) throws -> T?

    func delete(for key: String) throws
}
