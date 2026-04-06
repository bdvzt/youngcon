import SwiftUI

struct TabPageView: View {
    @Binding var activeTab: AppTab
    @Binding var previousTab: AppTab
    @Binding var isOverlayPresented: Bool

    var scheduleViewModel: ScheduleViewModel?

    private let allTabs = AppTab.allCases
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
            AppColor.appBackground.ignoresSafeArea()

            switch activeTab {
            case .schedule:
                if let scheduleViewModel {
                    ScheduleView(viewModel: scheduleViewModel)
                        .transition(slideTransition)
                } else {
                    ProgressView()
                        .tint(.white.opacity(0.6))
                        .transition(slideTransition)
                }
            case .map:
                LocationsView()
                    .transition(slideTransition)
            case .badge:
                BadgeView(isOverlayPresented: $isOverlayPresented)
                    .transition(slideTransition)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: activeTab)
        .gesture(swipeGesture)
    }

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
