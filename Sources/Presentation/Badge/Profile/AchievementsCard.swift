import SwiftUI

struct UnlockBurstEffect: View {
    let sticker: Sticker
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var particleAngles: [Double] = (0 ..< 8).map { Double($0) * 45 }
    @State private var particleRadii: [CGFloat] = Array(repeating: 0, count: 8)
    @State private var particleOpacities: [Double] = Array(repeating: 0, count: 8)

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColor.accentYellow.opacity(ringOpacity * 0.6), lineWidth: 2)
                .scaleEffect(ringScale)
                .frame(width: 120, height: 120)

            Circle()
                .stroke(AppColor.accentPink.opacity(ringOpacity * 0.4), lineWidth: 1)
                .scaleEffect(ringScale * 1.3)
                .frame(width: 120, height: 120)

            ForEach(0 ..< 8, id: \.self) { i in
                Circle()
                    .fill(i % 2 == 0 ? AppColor.accentYellow : AppColor.accentPink)
                    .frame(width: 5, height: 5)
                    .offset(
                        x: particleRadii[i] * cos(particleAngles[i] * .pi / 180),
                        y: particleRadii[i] * sin(particleAngles[i] * .pi / 180)
                    )
                    .opacity(particleOpacities[i])
            }

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(sticker.bgColor)
                        .frame(width: 64, height: 64)
                        .shadow(color: sticker.bgColor.opacity(0.6), radius: 16)

                    if let iconURL = sticker.icon {
                        AsyncImage(url: iconURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 26))
                                .foregroundColor(sticker.fgColor)
                        }
                        .frame(width: 34, height: 34)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 26))
                            .foregroundColor(sticker.fgColor)
                    }
                }

                VStack(spacing: 4) {
                    Text("Ачивка разблокирована!")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .foregroundColor(AppColor.accentYellow)

                    Text(sticker.name)
                        .font(.system(size: 16, weight: .black))
                        .tracking(-0.3)
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppColor.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [AppColor.accentYellow.opacity(0.5), AppColor.accentPink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: AppColor.accentYellow.opacity(0.15), radius: 30)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear { runAnimation() }
    }

    private func runAnimation() {
        // Appear
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.6)) {
            ringScale = 2.0
            ringOpacity = 1.0
        }
        for i in 0 ..< 8 {
            withAnimation(.easeOut(duration: 0.55).delay(Double(i) * 0.03)) {
                particleRadii[i] = 70
                particleOpacities[i] = 1.0
            }
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
            ringOpacity = 0
        }
        for i in 0 ..< 8 {
            withAnimation(.easeIn(duration: 0.35).delay(0.45)) {
                particleOpacities[i] = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                scale = 0.85
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isShowing = false
            }
        }
    }
}

struct AchievementsCard: View {
    let stickers: [Sticker]
    let unlockedCount: Int
    @Binding var selectedSticker: Sticker?
    @Binding var newlyUnlockedSticker: Sticker?

    @State private var animatedCells: Set<String> = []

    var body: some View {
        GradientBorderCard(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 20) {
                header
                GradientProgressBar(progress: Double(unlockedCount) / Double(stickers.isEmpty ? 1 : stickers.count))
                stickerGrid
            }
            .padding(24)
        }
        .onChange(of: newlyUnlockedSticker) { _, newVal in
            guard let newVal else { return }

            animatedCells.insert(newVal.id)

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                animatedCells.remove(newVal.id)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                newlyUnlockedSticker = nil
            }
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
                        colors: [AppColor.accentYellow, AppColor.accentPink],
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
                    StickerCell(
                        sticker: sticker,
                        isNewlyUnlocked: animatedCells.contains(sticker.id)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
