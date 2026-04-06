import SwiftUI

@main
struct YoungConApp: App {
    private let dependencyContainer = DependencyContainer.live()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencyContainer, dependencyContainer)
        }
    }
}
