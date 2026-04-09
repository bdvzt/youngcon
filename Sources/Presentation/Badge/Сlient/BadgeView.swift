import SwiftUI

struct BadgeView: View {
    @ObservedObject var viewModel: BadgeViewModel
    @Binding var isQRModalOpen: Bool
    @Binding var selectedSticker: Sticker?
    var onLogout: (() -> Void)?

    @State private var gradientOffset: CGFloat = 0

    private let appBackground = AppColor.appBackground

    var hasFixedHeader: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: hasFixedHeader ? 68 : 60)

                    if let profile = viewModel.profile {
                        BadgeCard(user: profile, isQRModalOpen: $isQRModalOpen)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        AchievementsCard(
                            stickers: viewModel.stickers,
                            unlockedCount: viewModel.stickers.filter(\.isUnlocked).count,
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

                    Color.clear.frame(height: 120)
                }
            }

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
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
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
