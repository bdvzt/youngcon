import SwiftUI

@main
struct YoungConApp: App {
    private let dependencyContainer = DependencyContainer.live()
    init() {
        UIRefreshControl.appearance().tintColor = YoungConAsset.accentYellow.color
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencyContainer, dependencyContainer)
        }
    }
}
