import SwiftUI

struct StickerDetailModal: View {
    @Binding var selectedSticker: Sticker?

    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor
    private let accentPurple = YoungConAsset.accentPurple.swiftUIColor
    private let cardBackground = YoungConAsset.cardBackground.swiftUIColor

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            if let sticker = selectedSticker {
                VStack(alignment: .leading, spacing: 20) {
                    headerRow(sticker: sticker)
                    Text(sticker.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                        .lineSpacing(4)
                }
                .padding(24)
                .frame(maxWidth: 300)
                .background(modalBackground)
                .transition(.scale(scale: 0.94).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedSticker)
    }

    private func headerRow(sticker: Sticker) -> some View {
        HStack(alignment: .top) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(sticker.bgColor)
                        .frame(width: 48, height: 48)
                    Image(systemName: sticker.icon)
                        .font(.system(size: 20))
                        .foregroundColor(sticker.fgColor)
                }
                .saturation(sticker.isUnlocked ? 1 : 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(sticker.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(sticker.isUnlocked ? "✓ Разблокировано" : "Заблокировано")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.05)
                        .textCase(.uppercase)
                        .foregroundColor(
                            sticker.isUnlocked ? accentYellow : .white.opacity(0.2)
                        )
                }
            }
            Spacer()
            closeButton
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
    }

    private var modalBackground: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accentYellow.opacity(0.2),
                                Color.clear,
                                Color.clear,
                                accentPurple.opacity(0.2),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.25)) { selectedSticker = nil }
    }
}
