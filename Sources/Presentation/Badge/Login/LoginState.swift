import SwiftUI

@MainActor
final class LoginState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false

    func login(email _: String, password _: String) async -> Bool {
        isLoading = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            isLoading = false
            isLoggedIn = true
        }

        return true
    }

    func logout() {
        isLoggedIn = false
    }
}
