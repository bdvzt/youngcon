final class AuthRepository: AuthRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var tokenStorage: TokenStorageProtocol

    init(networkService: NetworkServiceProtocol, tokenStorage: TokenStorageProtocol) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }

    func login(email: String, password: String) async throws {
        let dto = LoginRequestDTO(email: email, password: password)
        let endpoint = LoginEndpoint(body: dto)
        let response = try await networkService.requestDecodable(
            endpoint,
            as: AccessToken.self
        )
        tokenStorage.accessToken = response.token
    }

    func logout() async throws {
        let endpoint = LogoutEndPoint()
        try await networkService.request(endpoint)
        tokenStorage.accessToken = nil
    }
}
