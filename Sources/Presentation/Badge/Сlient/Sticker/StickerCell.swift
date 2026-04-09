import SwiftUI

struct StickerCell: View {
    let sticker: Sticker
    var isNewlyUnlocked: Bool = false

    @State private var glowPulse = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if isNewlyUnlocked {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [AppColor.accentYellow, AppColor.accentPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: glowPulse ? 2.5 : 1.5
                        )
                        .frame(width: 52, height: 52)
                        .opacity(glowPulse ? 0.9 : 0.4)
                        .scaleEffect(glowPulse ? 1.12 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: glowPulse
                        )
                }

                Circle()
                    .fill(sticker.bgColor)
                    .frame(width: 44, height: 44)

                if let iconURL = sticker.icon {
                    AsyncImage(url: iconURL) { image in
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
                    Image(systemName: "star.fill")
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
                .fill(
                    isNewlyUnlocked
                        ? AppColor.accentYellow.opacity(0.06)
                        : Color.white.opacity(sticker.isUnlocked ? 0.02 : 0)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isNewlyUnlocked
                                ? LinearGradient(
                                    colors: [AppColor.accentYellow.opacity(0.4), AppColor.accentPink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.white.opacity(sticker.isUnlocked ? 0.06 : 0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            if isNewlyUnlocked {
                glowPulse = true
            }
        }
    }
}
