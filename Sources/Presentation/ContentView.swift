import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
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

struct MainTabView: View {
    @State private var activeTab: AppTab = .schedule

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#0A0B12").ignoresSafeArea()

            TabPageView(tab: activeTab)
                .ignoresSafeArea(edges: .bottom)

            BottomNavBar(activeTab: $activeTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabPageView: View {
    let tab: AppTab

    var body: some View {
        ZStack {
            Color(hex: "#0A0B12").ignoresSafeArea()

            VStack(spacing: 16) {

                Text(tab.label)
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
