import Foundation

final class UserDefaultsStore: UserDefaultsStoreProtocol {
    private let defaults = UserDefaults.standard

    func set(_ data: Data, for key: String) throws {
        defaults.set(data, forKey: key)
    }

    func setCodable(_ value: some Codable, for key: String) throws {
        let data = try JSONEncoder().encode(value)
        try set(data, for: key)
    }

    func get(for key: String) throws -> Data? {
        defaults.data(forKey: key)
    }

    func getCodable<T: Codable>(for key: String) throws -> T? {
        guard let data = try get(for: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func delete(for key: String) throws {
        defaults.removeObject(forKey: key)
    }
}
