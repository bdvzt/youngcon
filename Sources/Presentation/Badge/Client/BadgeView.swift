import SwiftUI

struct BadgeView: View {
    @ObservedObject var viewModel: BadgeViewModel
    @Binding var isQRModalOpen: Bool
    @Binding var selectedSticker: Sticker?
    var onLogout: (() -> Void)?

    @State private var gradientOffset: CGFloat = 0

    private let appBackground = AppColor.appBackground

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            contentScrollView
            topOverlay
            headerOverlay
            unlockOverlay
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
        .task {
            await viewModel.loadData()
            viewModel.startPolling(every: isQRModalOpen ? 1 : 30)
        }
        .onChange(of: isQRModalOpen) { _, isOpen in
            viewModel.startPolling(every: isOpen ? 1 : 30)
        }
        .onChange(of: viewModel.shouldCloseQR) { _, shouldClose in
            guard shouldClose else { return }

            isQRModalOpen = false
            viewModel.shouldCloseQR = false
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }

    private var contentScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: 60)

                profileContent

                Color.clear.frame(height: 120)
            }
        }
    }

    @ViewBuilder
    private var profileContent: some View {
        if let profile = viewModel.profile {
            BadgeCard(user: profile, isQRModalOpen: $isQRModalOpen)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            AchievementsCard(
                stickers: viewModel.stickers,
                unlockedCount: unlockedCount,
                selectedSticker: $selectedSticker,
                newlyUnlockedSticker: $viewModel.newlyUnlockedSticker
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
        } else if viewModel.isLoading {
            ProgressView()
                .tint(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
        }
    }

    private var unlockedCount: Int {
        viewModel.stickers.filter(\.isUnlocked).count
    }

    private var headerOverlay: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                logoView

                Spacer()

                logoutButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
        }
        .zIndex(21)
    }

    private var logoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    RadialGradient(
                        colors: [AppColor.accentYellow, .clear],
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
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
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var logoutButton: some View {
        if let onLogout {
            Button {
                onLogout()
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
    }

    @ViewBuilder
    private var unlockOverlay: some View {
        if let burstSticker = viewModel.newlyUnlockedSticker {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            viewModel.newlyUnlockedSticker = nil
                        }
                    }

                UnlockBurstEffect(
                    sticker: burstSticker,
                    isShowing: Binding(
                        get: { viewModel.newlyUnlockedSticker != nil },
                        set: { if !$0 { viewModel.newlyUnlockedSticker = nil } }
                    )
                )
            }
            .zIndex(100)
            .transition(.opacity)
        }
    }

    private var topOverlay: some View {
        VStack(spacing: 0) {
            appBackground
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)

            appBackground
                .frame(height: 52)

            LinearGradient(
                colors: [appBackground, appBackground.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)

            Spacer()
        }
        .zIndex(20)
        .allowsHitTesting(false)
    }
}
