import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let authorizationProvider: AuthorizationProvidingProtocol

    init(
        session: URLSession = .shared,
        authorizationProvider: AuthorizationProvidingProtocol
    ) {
        self.session = session
        self.authorizationProvider = authorizationProvider
    }

    func request(_ endpoint: EndPoint) async throws {
        let _: Data = try await send(endpoint)
    }

    func requestDecodable<T: Decodable>(_ endpoint: EndPoint, as: T.Type) async throws -> T {
        let data = try await send(endpoint)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    // MARK: - Private

    @discardableResult
    private func send(_ endpoint: EndPoint) async throws -> Data {
        var request = try URLRequestBuilder.build(from: endpoint)
        request = await authorizationProvider.addAuthorization(
            to: request,
            requirement: endpoint.authorization
        )

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.noResponse
        }

        if HTTPStatusCode.isSuccess(http.statusCode) {
            return data
        }

        if http.statusCode == HTTPStatusCode.unauthorized.rawValue {
            throw NetworkError.unauthorized
        }

        let message = String(data: data, encoding: .utf8)
        throw NetworkError.serverError(code: http.statusCode, message: message)
    }
}
