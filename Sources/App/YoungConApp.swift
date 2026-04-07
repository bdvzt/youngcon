import SwiftUI

@main
struct YoungConApp: App {
    private let dependencyContainer = DependencyContainer.makeForAppLaunch()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencyContainer, dependencyContainer)
        }
    }
}
