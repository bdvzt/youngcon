import Combine
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var authError: String?

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
        checkExistingSession()
    }

    private func checkExistingSession() {
        Task {
            do {
                let userProfile = try await authRepository.checkExistingSession()
                self.profile = userProfile
                self.isAuthenticated = true
            } catch {
                // Токена нет или он протух
                self.isAuthenticated = false
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        authError = nil

        do {
            try await authRepository.login(email: email, password: password)
            // После логина тоже проверяем через репозиторий
            let userProfile = try await authRepository.checkExistingSession()
            profile = userProfile
            isAuthenticated = true
        } catch {
            authError = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        Task {
            try? await authRepository.logout()
        }
        isAuthenticated = false
        profile = nil
    }
}
