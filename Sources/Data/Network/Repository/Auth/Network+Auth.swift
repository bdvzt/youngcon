extension NetworkService: AuthNetworkProtocol {
    func login(email: String, password: String) async throws {
        let dto = LoginRequestDTO(email: email, password: password)
        let endpoint = LoginEndpoint(body: dto)
        let response = try await requestDecodable(
            endpoint,
            as: AccessToken.self
        )
        tokenStorage.accessToken = response.token
    }

    func logout() async throws {
        let endpoint = LogoutEndPoint()
        try await request(endpoint)
    }
}
