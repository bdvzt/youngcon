import Foundation

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
        let response = try await networkService.requestDecodable(endpoint, as: AccessTokenDTO.self)
        tokenStorage.accessToken = response.token
    }

    func logout() async throws {
        let endpoint = LogoutEndPoint()
        try await networkService.request(endpoint)
        tokenStorage.accessToken = nil
    }

    func checkExistingSession() async throws -> UserProfile {
        guard tokenStorage.accessToken != nil else {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No token"]
            )
        }
        let endpoint = GetUserProfileEndpoint()
        let dto = try await networkService.requestDecodable(endpoint, as: UserProfileDTO.self)
        guard let profile = dto.toEntity() else {
            throw NSError(domain: "Auth", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert profile"])
        }
        return profile
    }
}
