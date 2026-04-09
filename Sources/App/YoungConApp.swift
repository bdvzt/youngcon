import SwiftUI

@main
struct YoungConApp: App {
    private let dependencyContainer = DependencyContainer.makeForAppLaunch()

    init() {
        AppFont.validateRegistration()
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch UITestLaunchScenario.current {
        case .none:
            ContentView()
                .environment(\.dependencyContainer, dependencyContainer)
        case .map:
            UITestMapRootView()
        }
    }
}
