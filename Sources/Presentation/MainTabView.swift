import SwiftUI

struct MainTabView: View {
    @State private var activeTab: AppTab = .schedule
    @State private var isOverlayPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            YoungConAsset.appBackground.swiftUIColor
                .ignoresSafeArea()

            TabPageView(tab: activeTab, isOverlayPresented: $isOverlayPresented)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(0)

            VStack(spacing: 0) {
                Spacer()
                BottomNavBar(activeTab: $activeTab, isOverlayPresented: isOverlayPresented)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1)
        }
    }
}
