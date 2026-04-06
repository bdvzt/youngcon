import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AppColor.appBackground.ignoresSafeArea()

            if isLoading {
                LoadingScreen(isLoading: $isLoading)
                    .transition(.opacity)
            } else {
                MainTabView()
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
