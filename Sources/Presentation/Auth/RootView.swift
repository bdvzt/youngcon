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
        ZStack {
            if appViewModel.isCheckingSession {
                AppColor.appBackground.ignoresSafeArea()
                    .transition(.opacity)
            } else if !appViewModel.isAuthenticated {
                LoginView(appViewModel: appViewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            } else {
                if appViewModel.profile?.role == .employee {
                    MainTabView(
                        container: container,
                        appViewModel: appViewModel,
                        tabs: AppTab.organizerTabs
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
                } else {
                    MainTabView(
                        container: container,
                        appViewModel: appViewModel,
                        tabs: AppTab.clientTabs
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appViewModel.isCheckingSession)
        .animation(.easeInOut(duration: 0.4), value: appViewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.4), value: appViewModel.profile?.role)
    }
}
