import SwiftUI

struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container
    @Environment(\.scenePhase) private var scenePhase

    @State private var scheduleViewModel: ScheduleViewModel?
    @State private var activeTab: AppTab = .schedule
    @State private var previousTab: AppTab = .schedule
    @State private var isOverlayPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.appBackground.ignoresSafeArea()

            TabPageView(
                activeTab: $activeTab,
                previousTab: $previousTab,
                isOverlayPresented: $isOverlayPresented,
                scheduleViewModel: scheduleViewModel
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
                let model = ScheduleViewModel(
                    festivalsRepository: container.festivalsRepository,
                    eventsRepository: container.eventsRepository,
                    zoneRepository: container.zoneRepository,
                    speakersRepository: container.speakersRepository
                )
                scheduleViewModel = model
                await model.load()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, let scheduleViewModel else { return }
            Task { await scheduleViewModel.syncCurrentEventLiveActivity() }
        }
    }
}
