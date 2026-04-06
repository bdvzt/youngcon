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

    private let appBackground = YoungConAsset.appBackground.swiftUIColor
    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()
            ambientGlows

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
                (isOverlayPresented ? Color.clear : appBackground)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
                (isOverlayPresented ? Color.clear : appBackground)
                    .frame(height: 52)
                if !isOverlayPresented {
                    LinearGradient(
                        colors: [appBackground, appBackground.opacity(0)],
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

            VStack(spacing: 0) {
                glowingLogo
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                Spacer()
            }
            .zIndex(21)
            .allowsHitTesting(false)
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .onDisappear { isOverlayPresented = false }
        .onChange(of: isQRModalOpen) { syncOverlay() }
        .onChange(of: selectedSticker) { syncOverlay() }
    }

    private func syncOverlay() {
        isOverlayPresented = isQRModalOpen || (selectedSticker != nil)
    }

    private var glowingLogo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [accentYellow, Color.clear]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 60)
                .blur(radius: 20)
                .opacity(0.3)
                .allowsHitTesting(false)
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: accentYellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ambientGlows: some View {
        ZStack {
            Circle()
                .fill(YoungConAsset.accentPurple.swiftUIColor)
                .frame(width: 320, height: 320)
                .blur(radius: 100)
                .opacity(0.24)
                .offset(x: -130, y: -130)
                .allowsHitTesting(false)

            Circle()
                .fill(YoungConAsset.accentYellow.swiftUIColor)
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .opacity(0.16)
                .offset(x: 120, y: 320)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
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
