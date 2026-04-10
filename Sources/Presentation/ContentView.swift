import SwiftUI

struct ContentView: View {
    @Environment(\.dependencyContainer) private var container
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AppColor.appBackground.ignoresSafeArea()

            if isLoading {
                LoadingScreen(isLoading: $isLoading)
                    .transition(.opacity)
            } else {
                RootView(container: container)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isLoading)
    }
}

#Preview {
    ContentView()
        .environment(\.dependencyContainer, .preview)
}
