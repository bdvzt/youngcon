import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    private let bg = YoungConAsset.appBackground.swiftUIColor

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

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
}
