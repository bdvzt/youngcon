import SwiftUI

struct MainTabView: View {
    private let container: DependencyContainer
    private let tabs: [AppTab]

    @ObservedObject var appViewModel: AppViewModel

    @State private var mapViewModel: MapViewModel?
    @State private var scheduleViewModel: ScheduleViewModel?
    @State private var badgeViewModel: BadgeViewModel?

    @State private var activeTab: AppTab
    @State private var previousTab: AppTab
    @State private var isQRModalOpen = false
    @State private var selectedSticker: Sticker?
    @State private var isOverlayPresented = false
    @State private var showLogoutConfirm = false

    init(
        container: DependencyContainer,
        appViewModel: AppViewModel,
        tabs: [AppTab] = AppTab.clientTabs
    ) {
        self.container = container
        self.tabs = tabs
        self.appViewModel = appViewModel

        let defaultTab: AppTab = tabs.contains(.schedule) ? .schedule : tabs[0]
        _activeTab = State(initialValue: defaultTab)
        _previousTab = State(initialValue: defaultTab)
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppColor.appBackground.ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(AppColor.accentPurple.opacity(0.35))
                    .frame(width: 320, height: 320)
                    .blur(radius: 100)
                    .offset(x: -130, y: -130)

                Circle()
                    .fill(AppColor.accentYellow.opacity(0.28))
                    .frame(width: 288, height: 288)
                    .blur(radius: 90)
                    .offset(x: 130, y: 300)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            .zIndex(0)

            TabPageView(
                activeTab: $activeTab,
                previousTab: $previousTab,
                isOverlayPresented: $isOverlayPresented,
                container: container,
                appViewModel: appViewModel,
                tabs: tabs,
                mapViewModel: mapViewModel,
                scheduleViewModel: scheduleViewModel,
                badgeViewModel: badgeViewModel,
                isQRModalOpen: $isQRModalOpen,
                selectedSticker: $selectedSticker,
                onLogout: {
                    withAnimation { showLogoutConfirm = true }
                }
            )
            .ignoresSafeArea(edges: .top)
            .zIndex(1)

            if selectedSticker != nil {
                StickerDetailModal(selectedSticker: $selectedSticker)
                    .zIndex(100)
            }

            if isQRModalOpen, let profile = badgeViewModel?.profile {
                let qrString = profile.qrCode.isEmpty ? profile.id : profile.qrCode
                QRModal(qrString: qrString, userID: profile.id, isOpen: $isQRModalOpen)
                    .zIndex(100)
            }

            if let burstSticker = badgeViewModel?.newlyUnlockedSticker, activeTab == .badge {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                badgeViewModel?.newlyUnlockedSticker = nil
                            }
                        }

                    UnlockBurstEffect(
                        sticker: burstSticker,
                        isShowing: Binding(
                            get: { badgeViewModel?.newlyUnlockedSticker != nil },
                            set: { if !$0 { badgeViewModel?.newlyUnlockedSticker = nil } }
                        )
                    )
                }
                .zIndex(100)
                .transition(.opacity)
            }

            if showLogoutConfirm {
                LogoutModalView(
                    isPresented: $showLogoutConfirm,
                    onConfirm: {
                        appViewModel.logout()
                    }
                )
                .zIndex(200)
                .transition(.opacity)
            }

            BottomNavBar(
                activeTab: Binding(
                    get: { activeTab },
                    set: { newTab in
                        previousTab = activeTab
                        activeTab = newTab
                    }
                ),
                tabs: tabs,
                isOverlayPresented: isOverlayPresented
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .zIndex(90)
        }
        .animation(nil, value: activeTab)
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

            if mapViewModel == nil {
                let model = MapViewModel(
                    floorsRepository: container.floorsRepository,
                    zoneRepository: container.zoneRepository
                )
                mapViewModel = model
                await model.load()
            }

            if badgeViewModel == nil {
                let model = BadgeViewModel(
                    usersRepository: container.usersRepository,
                    achievementsRepository: container.achievementsRepository
                )
                badgeViewModel = model
                await model.loadData()
                model.startPolling()
            }
        }
        .onChange(of: activeTab) { oldValue, newValue in
            guard oldValue != newValue else { return }
            previousTab = oldValue

            if oldValue == .badge {
                selectedSticker = nil
                isQRModalOpen = false
                isOverlayPresented = false
            }
        }
        .onChange(of: isQRModalOpen) { _, _ in syncOverlay() }
        .onChange(of: selectedSticker) { _, _ in syncOverlay() }
        .onChange(of: badgeViewModel?.newlyUnlockedSticker) { _, _ in syncOverlay() }
        .onDisappear {
            badgeViewModel?.stopPolling()
        }
    }

    private func syncOverlay() {
        let hasModal = isQRModalOpen
            || (selectedSticker != nil)
            || (badgeViewModel?.newlyUnlockedSticker != nil)

        let newState = activeTab == .badge && hasModal

        if newState != isOverlayPresented {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOverlayPresented = newState
            }
        }
    }
}

// MARK: - Custom Logout Modal View

private struct LogoutModalView: View {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            // Затемненный фон, как у StickerDetailModal
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }

            // Карточка в стиле ачивок
            VStack(spacing: 24) {
                Text("Выйти из аккаунта?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Вы уверены, что хотите выйти из своего профиля?")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Кнопки
                VStack(spacing: 12) {
                    Button {
                        isPresented = false
                        onConfirm()
                    } label: {
                        Text("Выйти")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.8))
                            )
                    }

                    Button {
                        withAnimation { isPresented = false }
                    } label: {
                        Text("Отмена")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    .background(Capsule().fill(Color.white.opacity(0.05)))
                            )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(AppColor.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColor.accentYellow.opacity(0.2),
                                        Color.clear,
                                        Color.clear,
                                        AppColor.accentPurple.opacity(0.2),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}
