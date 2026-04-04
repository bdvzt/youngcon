import SwiftUI

struct BadgeView: View {
    @Binding var isOverlayPresented: Bool
    @State private var isQRModalOpen = false
    @State private var selectedSticker: Sticker?

    private let stickers = Sticker.mockData
    private var unlockedCount: Int {
        stickers.count(where: { $0.isUnlocked })
    }

    private let appBackground = YoungConAsset.appBackground.swiftUIColor
    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Color.clear.frame(height: 52)
                    BadgeCard(isQRModalOpen: $isQRModalOpen)
                    AchievementsCard(
                        stickers: stickers,
                        unlockedCount: unlockedCount,
                        selectedSticker: $selectedSticker
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }

            if selectedSticker != nil {
                StickerDetailModal(selectedSticker: $selectedSticker)
                    .zIndex(10)
            }

            if isQRModalOpen {
                QRModal(isOpen: $isQRModalOpen)
                    .zIndex(10)
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
        .onAppear { syncOverlay() }
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
}
