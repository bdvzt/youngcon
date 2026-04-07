import SwiftUI

struct StickerCell: View {
    let sticker: Sticker

    private var isURL: Bool {
        sticker.icon.hasPrefix("http://") || sticker.icon.hasPrefix("https://")
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(sticker.bgColor)
                    .frame(width: 44, height: 44)

                if isURL {
                    AsyncImage(url: URL(string: sticker.icon)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundColor(sticker.fgColor)
                    }
                    .frame(width: 24, height: 24)
                    .foregroundColor(sticker.fgColor)
                } else {
                    Image(systemName: sticker.icon)
                        .font(.system(size: 18))
                        .foregroundColor(sticker.fgColor)
                }
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
