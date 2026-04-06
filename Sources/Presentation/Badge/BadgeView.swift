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

            AppScreenTopFadeOverlay(background: appBackground, isObscured: isOverlayPresented)
                .animation(.easeInOut(duration: 0.2), value: isOverlayPresented)
                .zIndex(20)

            VStack(spacing: 0) {
                AppScreenLogoBar()
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
}
