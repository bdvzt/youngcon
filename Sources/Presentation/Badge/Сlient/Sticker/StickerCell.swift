import SwiftUI

struct StickerCell: View {
    let sticker: Sticker
    var isNewlyUnlocked: Bool = false

    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [AppColor.accentYellow, AppColor.accentPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 52, height: 52)
                    .opacity(isAnimating ? glowOpacity : 0)
                    .scaleEffect(glowScale)

                Circle()
                    .fill(sticker.bgColor)
                    .frame(width: 44, height: 44)

                if let iconURL = sticker.icon {
                    AsyncImage(url: iconURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "star.fill")
                            .foregroundColor(sticker.fgColor)
                    }
                    .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "star.fill")
                        .foregroundColor(sticker.fgColor)
                }
            }

            Text(sticker.name)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(height: 80)
        .onChange(of: isNewlyUnlocked) { _, isActive in
            if isActive {
                startPulse()
            } else {
                stopPulseSmooth()
            }
        }
    }

    private func startPulse() {
        isAnimating = true

        Task {
            while isAnimating {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        glowScale = 1.12
                        glowOpacity = 0.9
                    }
                }

                try? await Task.sleep(for: .milliseconds(600))

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        glowScale = 1.0
                        glowOpacity = 0.4
                    }
                }

                try? await Task.sleep(for: .milliseconds(600))
            }
        }
    }

    private func stopPulseSmooth() {
        isAnimating = false

        withAnimation(.easeOut(duration: 0.4)) {
            glowScale = 1.0
            glowOpacity = 0.0
        }
    }
}
