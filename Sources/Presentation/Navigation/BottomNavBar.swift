import SwiftUI

struct BottomNavBar: View {
    @Binding var activeTab: AppTab
    var isOverlayPresented: Bool = false

    private let background = YoungConAsset.appBackground.swiftUIColor

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5)

            HStack(alignment: .center) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabItemView(
                        tab: tab,
                        isActive: activeTab == tab
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            activeTab = tab
                        }
                    }
                    .allowsHitTesting(!isOverlayPresented)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 0)
        }
        .background(
            background
                .opacity(0.85)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
