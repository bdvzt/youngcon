import SwiftUI

struct BadgeView: View {
    @Binding var isOverlayPresented: Bool
    @State private var isQRModalOpen = false
    @State private var selectedSticker: Sticker?
    @StateObject private var viewModel: BadgeViewModel

    init(container: DependencyContainer, isOverlayPresented: Binding<Bool>) {
        _isOverlayPresented = isOverlayPresented
        _viewModel = StateObject(wrappedValue: BadgeViewModel(
            usersRepository: container.usersRepository,
            achievementsRepository: container.achievementsRepository
        ))
    }

    var body: some View {
        ZStack {
            Color.clear

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Color.clear.frame(height: 52)
                    if let profile = viewModel.profile {
                        BadgeCard(user: profile, isQRModalOpen: $isQRModalOpen)
                    } else {
                        let fallbackCard = BadgeCard(
                            user: UserProfile.placeholder,
                            isQRModalOpen: $isQRModalOpen
                        )
                        if viewModel.isLoading {
                            fallbackCard.redacted(reason: .placeholder)
                        } else {
                            fallbackCard
                        }
                    }
                    AchievementsCard(
                        stickers: viewModel.stickers,
                        unlockedCount: viewModel.stickers.count(where: { $0.isUnlocked }),
                        selectedSticker: $selectedSticker
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
            .refreshable {
                await viewModel.loadData()
            }

            if selectedSticker != nil {
                StickerDetailModal(selectedSticker: $selectedSticker)
                    .zIndex(10)
            }

            if isQRModalOpen {
                if let profile = viewModel.profile {
                    let qrString = profile.qrCode.isEmpty ? profile.id : profile.qrCode
                    QRModal(qrString: qrString, userID: profile.id, isOpen: $isQRModalOpen)
                        .zIndex(10)
                }
            }

            VStack(spacing: 0) {
                (isOverlayPresented ? Color.clear : AppColor.appBackground)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
                (isOverlayPresented ? Color.clear : AppColor.appBackground)
                    .frame(height: 52)
                if !isOverlayPresented {
                    LinearGradient(
                        colors: [
                            AppColor.appBackground,
                            AppColor.appBackground.opacity(0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 32)
                }
                Spacer()
            }
            .animation(.easeInOut(duration: 0.2), value: isOverlayPresented)
            .zIndex(20)
            .allowsHitTesting(false)

            GeometryReader { geo in
                VStack(spacing: 0) {
                    glowingLogo
                        .padding(.horizontal, 20)
                        .padding(.top, geo.safeAreaInsets.top + 8)
                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .top)
            .zIndex(21)
            .allowsHitTesting(false)
        }
        .task {
            await viewModel.loadData()
        }
        .onDisappear { isOverlayPresented = false }
        .onChange(of: isQRModalOpen) { _, _ in syncOverlay() }
        .onChange(of: selectedSticker) { _, _ in syncOverlay() }
    }

    private func syncOverlay() {
        isOverlayPresented = isQRModalOpen || (selectedSticker != nil)
    }

    private var glowingLogo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [AppColor.accentYellow, Color.clear]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 60)
                .blur(radius: 20)
                .opacity(0.3)
                .padding(-30)
                .allowsHitTesting(false)
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: AppColor.accentYellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension UserProfile {
    static let placeholder = UserProfile(
        id: "00000000-0000-0000-0000-000000000000",
        firstName: "Loading",
        lastName: "User",
        email: "loading@example.com",
        qrCode: "loading",
        major: .frontend,
        role: .client
    )
}
