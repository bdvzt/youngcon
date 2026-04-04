import SwiftUI

struct TabPageView: View {
    @Binding var activeTab: AppTab
    @Binding var previousTab: AppTab
    @Binding var isOverlayPresented: Bool

    private let allTabs = AppTab.allCases
    private let background = YoungConAsset.appBackground.swiftUIColor

    private var slideDirection: CGFloat {
        activeTab.index > previousTab.index ? 1 : -1
    }

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: slideDirection > 0 ? .trailing : .leading),
            removal: .move(edge: slideDirection > 0 ? .leading : .trailing)
        )
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            switch activeTab {
            case .schedule:
                VStack(spacing: 16) {
                    Text("Расписание")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                }
                .transition(slideTransition)
            case .map:
                VStack(spacing: 16) {
                    Text("Карта")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                }
                .transition(slideTransition)
            case .badge:
                BadgeView(isOverlayPresented: $isOverlayPresented)
                    .transition(slideTransition)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: activeTab)
        .gesture(swipeGesture)
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 40, coordinateSpace: .local)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < -40 {
                    switchToNext()
                } else if value.translation.width > 40 {
                    switchToPrevious()
                }
            }
    }

    private func switchToNext() {
        guard let current = allTabs.firstIndex(of: activeTab),
              current + 1 < allTabs.count else { return }
        previousTab = activeTab
        withAnimation(.easeInOut(duration: 0.3)) {
            activeTab = allTabs[current + 1]
        }
    }

    private func switchToPrevious() {
        guard let current = allTabs.firstIndex(of: activeTab),
              current - 1 >= 0 else { return }
        previousTab = activeTab
        withAnimation(.easeInOut(duration: 0.3)) {
            activeTab = allTabs[current - 1]
        }
    }
}
