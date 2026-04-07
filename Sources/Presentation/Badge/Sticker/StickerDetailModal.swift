import SwiftUI

struct StickerDetailModal: View {
    @Binding var selectedSticker: Sticker?
    @State private var displayedSticker: Sticker?
    @State private var isVisible = false

    var body: some View {
        ZStack {
            Color.black.opacity(isVisible ? 0.9 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            if let sticker = displayedSticker {
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
                .scaleEffect(isVisible ? 1 : 0.94)
                .opacity(isVisible ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isVisible)
        .onAppear {
            guard let selectedSticker else { return }
            displayedSticker = selectedSticker
            isVisible = true
        }
        .onChange(of: selectedSticker) { _, newValue in
            guard let newValue else { return }
            displayedSticker = newValue
            isVisible = true
        }
    }

    private func headerRow(sticker: Sticker) -> some View {
        HStack(alignment: .top) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(sticker.bgColor)
                        .frame(width: 48, height: 48)

                    if sticker.icon.hasPrefix("http://") || sticker.icon.hasPrefix("https://") {
                        AsyncImage(url: URL(string: sticker.icon)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundColor(sticker.fgColor)
                        }
                        .frame(width: 26, height: 26)
                        .foregroundColor(sticker.fgColor)
                    } else {
                        Image(systemName: sticker.icon)
                            .font(.system(size: 20))
                            .foregroundColor(sticker.fgColor)
                    }
                }
                .saturation(sticker.isUnlocked ? 1 : 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(sticker.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(sticker.isUnlocked ? "Разблокировано" : "Заблокировано")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.05)
                        .textCase(.uppercase)
                        .foregroundColor(
                            sticker.isUnlocked ? AppColor.accentYellow : .white.opacity(0.2)
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
            .fill(AppColor.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColor.accentYellow.opacity(0.2),
                                Color.clear,
                                Color.clear,
                                AppColor.accentPurple.opacity(0.2),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    private func dismiss() {
        guard displayedSticker != nil else { return }
        isVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            selectedSticker = nil
            displayedSticker = nil
        }
    }
}
