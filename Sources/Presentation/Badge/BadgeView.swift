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

            VStack {
                glowingLogo.padding(.horizontal, 20)
                Spacer()
            }
            .zIndex(20)
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
