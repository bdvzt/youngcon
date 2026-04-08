import SwiftUI

struct RootView: View {
    @StateObject private var appViewModel: AppViewModel
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
        _appViewModel = StateObject(wrappedValue: AppViewModel(
            authRepository: container.authRepository
        ))
    }

    var body: some View {
        Group {
            if !appViewModel.isAuthenticated {
                // Показываем LoginView напрямую, без WelcomeView
                LoginView(appViewModel: appViewModel)
            } else if appViewModel.profile?.role == .employee {
                OrganizerView(container: container, appViewModel: appViewModel)
            } else {
                MainTabView(container: container)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: appViewModel.profile?.role)
    }
}
