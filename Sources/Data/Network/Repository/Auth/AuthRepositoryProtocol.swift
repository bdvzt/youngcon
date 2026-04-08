protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws
    func logout() async throws
    func checkExistingSession() async throws -> UserProfile
}
