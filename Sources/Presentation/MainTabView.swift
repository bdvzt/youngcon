import SwiftUI

struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container

    @State private var scheduleViewModel: ScheduleViewModel?
    @State private var activeTab: AppTab = .schedule
    @State private var previousTab: AppTab = .schedule
    @State private var isOverlayPresented = false

    private let background = YoungConAsset.appBackground.swiftUIColor

    var body: some View {
        ZStack(alignment: .bottom) {
            background.ignoresSafeArea()

            TabPageView(
                activeTab: $activeTab,
                previousTab: $previousTab,
                isOverlayPresented: $isOverlayPresented,
                scheduleTab: {
                    ScheduleRootView(viewModel: scheduleViewModel)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(0)

            VStack(spacing: 0) {
                Spacer()
                BottomNavBar(
                    activeTab: Binding(
                        get: { activeTab },
                        set: { newTab in
                            previousTab = activeTab
                            activeTab = newTab
                        }
                    ),
                    isOverlayPresented: isOverlayPresented
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1)
        }
        .task {
            if scheduleViewModel == nil {
                scheduleViewModel = container.makeScheduleViewModel()
            }
            await scheduleViewModel?.load()
        }
    }
}
