import Foundation

protocol KeyValueStoreProtocol {
    func set(_ data: Data, for key: String) throws

    func get(for key: String) throws -> Data?

    func delete(for key: String) throws
}

protocol UserDefaultsStoreProtocol {
    func set(_ data: Data, for key: String) throws
    func setCodable(_ value: some Codable, for key: String) throws

    func get(for key: String) throws -> Data?
    func getCodable<T: Codable>(for key: String) throws -> T?

    func delete(for key: String) throws
}
