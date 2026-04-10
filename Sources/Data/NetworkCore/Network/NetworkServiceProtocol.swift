import Foundation

protocol NetworkServiceProtocol {
    func request(_ endpoint: Endpoint) async throws
    func requestDecodable<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}
