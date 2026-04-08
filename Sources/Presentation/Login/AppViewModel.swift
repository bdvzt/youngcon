import Combine
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isCheckingSession = true
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
            defer { isCheckingSession = false }
            do {
                let userProfile = try await authRepository.checkExistingSession()
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.profile = userProfile
                    self.isAuthenticated = true
                }
            } catch {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isAuthenticated = false
                }
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        authError = nil
        do {
            try await authRepository.login(email: email, password: password)
            let userProfile = try await authRepository.checkExistingSession()
            withAnimation(.easeInOut(duration: 0.4)) {
                self.profile = userProfile
                self.isAuthenticated = true
            }
        } catch {
            authError = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        Task {
            try? await authRepository.logout()
        }
        withAnimation(.easeInOut(duration: 0.4)) {
            isAuthenticated = false
            profile = nil
        }
    }
}
