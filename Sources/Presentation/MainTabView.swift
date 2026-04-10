import SwiftUI

struct MainTabView: View {
    private let container: DependencyContainer
    private let tabs: [AppTab]
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var appViewModel: AppViewModel

    @State private var mapViewModel: MapViewModel?
    @State private var scheduleViewModel: ScheduleViewModel?
    @State private var badgeViewModel: BadgeViewModel?
    @State private var organizerViewModel: OrganizerViewModel?

    @State private var activeTab: AppTab
    @State private var previousTab: AppTab
    @State private var isQRModalOpen = false
    @State private var selectedSticker: Sticker?
    @State private var isOverlayPresented = false
    @State private var showLogoutConfirm = false
    @State private var gradientOffset: CGFloat = 0

    private var shouldShowLogoutButton: Bool {
        let isOrganizerMode = tabs.contains(.scanner)

        if isOrganizerMode {
            return activeTab == .scanner
        } else {
            return activeTab == .badge
        }
    }

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

            backgroundBlobsView
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
                onLogout: { withAnimation { showLogoutConfirm = true } }
            )
            .ignoresSafeArea(edges: .top)
            .zIndex(1)

            headerBar
                .zIndex(50)

            modalsLayer
                .zIndex(40)

            if showLogoutConfirm {
                LogoutModalView(
                    isPresented: $showLogoutConfirm,
                    onConfirm: { appViewModel.logout() }
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
        .task { await loadAllViewModels() }
        .onChange(of: activeTab) { _, newValue in handleTabChange(to: newValue) }
        .onChange(of: isQRModalOpen) { _, _ in syncOverlay() }
        .onChange(of: selectedSticker) { _, _ in syncOverlay() }
        .onChange(of: badgeViewModel?.newlyUnlockedSticker) { _, _ in syncOverlay() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, let scheduleViewModel else { return }
            Task { await scheduleViewModel.syncCurrentEventLiveActivity() }
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
        .onDisappear {
            badgeViewModel?.stopPolling()
            scheduleViewModel?.stopPolling()
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                AppColor.appBackground
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
                AppColor.appBackground
                    .frame(height: 52)
                LinearGradient(
                    colors: [AppColor.appBackground, AppColor.appBackground.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)
                Spacer()
            }
            .zIndex(20)
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    logoWithGlowEffect

                    Spacer()

                    if shouldShowLogoutButton {
                        logoutButton
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
            }
            .zIndex(21)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: shouldShowLogoutButton)
        }
    }

    // MARK: - Logo Component

    private var logoWithGlowEffect: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(RadialGradient(
                    colors: [AppColor.accentYellow, .clear],
                    center: .center,
                    startRadius: 5,
                    endRadius: 40
                ))
                .frame(width: 80, height: 60)
                .blur(radius: 20)
                .opacity(0.35)
                .allowsHitTesting(false)

            YoungConAsset.logo.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: AppColor.accentYellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            withAnimation { showLogoutConfirm = true }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 10, weight: .bold))
                Text("Выйти")
                    .font(AppFont.geo(12, weight: .bold))
            }
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .background(Capsule().fill(Color.white.opacity(0.05)))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background Blobs

    private var backgroundBlobsView: some View {
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
    }

    // MARK: - Modals Layer

    @ViewBuilder
    private var modalsLayer: some View {
        if selectedSticker != nil {
            StickerDetailModal(selectedSticker: $selectedSticker)
        }

        if isQRModalOpen, let profile = badgeViewModel?.profile {
            let qrString = profile.qrCode.isEmpty ? profile.id : profile.qrCode
            QRModal(qrString: qrString, userID: profile.id, isOpen: $isQRModalOpen)
        }

        if let burstSticker = badgeViewModel?.newlyUnlockedSticker, activeTab == .badge {
            unlockBurstView(sticker: burstSticker)
        }
    }

    private func unlockBurstView(sticker: Sticker) -> some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { badgeViewModel?.newlyUnlockedSticker = nil }
                }

            UnlockBurstEffect(
                sticker: sticker,
                isShowing: Binding(
                    get: { badgeViewModel?.newlyUnlockedSticker != nil },
                    set: { if !$0 { badgeViewModel?.newlyUnlockedSticker = nil } }
                )
            )
        }
    }

    // MARK: - Data Loading

    private func loadAllViewModels() async {
        if scheduleViewModel == nil {
            let model = ScheduleViewModel(
                festivalsRepository: container.festivalsRepository,
                eventsRepository: container.eventsRepository,
                zoneRepository: container.zoneRepository,
                speakersRepository: container.speakersRepository,
                usersRepository: container.usersRepository
            )
            scheduleViewModel = model
            await model.load()
            model.startPolling(every: 30)
        }

        if mapViewModel == nil {
            let model = MapViewModel(
                floorsRepository: container.floorsRepository,
                zoneRepository: container.zoneRepository
            )
            mapViewModel = model
            await model.load()
            model.startPolling(every: 120)
        }

        if badgeViewModel == nil {
            let model = BadgeViewModel(
                usersRepository: container.usersRepository,
                achievementsRepository: container.achievementsRepository
            )
            badgeViewModel = model
            await model.loadData()
        }

        if organizerViewModel == nil, appViewModel.profile?.role == .employee {
            let model = OrganizerViewModel(
                achievementsRepository: container.achievementsRepository
            )
            organizerViewModel = model
        }
    }

    // MARK: - Actions

    private func handleTabChange(to newTab: AppTab) {
        guard previousTab != newTab else { return }

        if previousTab == .badge {
            selectedSticker = nil
            isQRModalOpen = false
            isOverlayPresented = false
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
