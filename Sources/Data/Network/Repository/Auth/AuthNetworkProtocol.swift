protocol AuthNetworkProtocol {
    func login(email: String, password: String) async throws
    func logout() async throws
}
