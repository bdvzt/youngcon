import SwiftUI

struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container

    @State private var mapViewModel: MapViewModel?
    @State private var scheduleViewModel: ScheduleViewModel?
    @State private var activeTab: AppTab = .schedule
    @State private var previousTab: AppTab = .schedule
    @State private var isOverlayPresented = false
    @State private var didAttemptAutoLogin = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.appBackground.ignoresSafeArea()
            Circle()
                .fill(AppColor.accentPurple.opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 100)
                .offset(x: -130, y: -130)
                .allowsHitTesting(false)
            Circle()
                .fill(AppColor.accentYellow.opacity(0.28))
                .frame(width: 288, height: 288)
                .blur(radius: 90)
                .offset(x: 130, y: 300)
                .allowsHitTesting(false)

            TabPageView(
                activeTab: $activeTab,
                previousTab: $previousTab,
                isOverlayPresented: $isOverlayPresented,
                container: container,
                mapViewModel: mapViewModel,
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
            if !didAttemptAutoLogin {
                didAttemptAutoLogin = true
                do {
                    try await container.authRepository.login(
                        email: "yaganova@gmail.com",
                        password: "12345678"
                    )
                } catch {
                    print("Auto login failed: \(error)")
                }
            }

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

            if mapViewModel == nil {
                let model = MapViewModel(
                    floorsRepository: container.floorsRepository,
                    zoneRepository: container.zoneRepository
                )
                mapViewModel = model
                await model.load()
            }
        }
    }
}
