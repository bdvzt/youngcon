import SwiftUI

struct AchievementsCard: View {
    let stickers: [Sticker]
    let unlockedCount: Int
    @Binding var selectedSticker: Sticker?

    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor
    private let accentPink = YoungConAsset.accentPink.swiftUIColor

    var body: some View {
        GradientBorderCard(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 20) {
                header
                GradientProgressBar(progress: Double(unlockedCount) / Double(stickers.count))
                stickerGrid
            }
            .padding(24)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Ачивки")
                    .font(.system(size: 20, weight: .black))
                    .tracking(-0.5)
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                Text("Собери все — получи мерч")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.2))
            }
            Spacer()
            Text("\(unlockedCount)/\(stickers.count)")
                .font(.system(size: 11, weight: .black))
                .tracking(0.1)
                .textCase(.uppercase)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [accentYellow, accentPink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .rotationEffect(.degrees(1.2))
        }
    }

    private var stickerGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
            spacing: 12
        ) {
            ForEach(stickers) { sticker in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedSticker = sticker
                    }
                } label: {
                    StickerCell(sticker: sticker)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Ячейка стикера

private struct StickerCell: View {
    let sticker: Sticker

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(sticker.bgColor)
                    .frame(width: 44, height: 44)
                Image(systemName: sticker.icon)
                    .font(.system(size: 18))
                    .foregroundColor(sticker.fgColor)
            }
            .opacity(sticker.isUnlocked ? 1 : 0.3)
            .saturation(sticker.isUnlocked ? 1 : 0)

            Text(sticker.name)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.05)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(sticker.isUnlocked ? 0.02 : 0))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color.white.opacity(sticker.isUnlocked ? 0.06 : 0.02),
                            lineWidth: 1
                        )
                )
        )
    }
}
