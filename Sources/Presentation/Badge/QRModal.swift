import SwiftUI

struct QRModal: View {
    @Binding var isOpen: Bool

    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor
    private let accentPurple = YoungConAsset.accentPurple.swiftUIColor
    private let cardBackground = YoungConAsset.cardBackground.swiftUIColor

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                headerRow
                    .padding(.bottom, 24)
                qrCode
                    .padding(.bottom, 24)
                Text("Покажите этот код на входе или на стендах партнёров")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                badgeNumber
            }
            .padding(32)
            .frame(maxWidth: 300)
            .background(modalBackground)
        }
        .animation(.easeInOut(duration: 0.3), value: isOpen)
    }

    private var headerRow: some View {
        HStack {
            Text("Отсканируй")
                .font(.system(size: 18, weight: .black))
                .tracking(-0.5)
                .textCase(.uppercase)
                .foregroundColor(.white)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.06))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var qrCode: some View {
        ZStack {
            CornerMarks(color: accentYellow)
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: 224, height: 224)
    }

    private var badgeNumber: some View {
        Text("#YY-1024")
            .font(.system(size: 14, weight: .bold))
            .tracking(0.1)
            .textCase(.uppercase)
            .foregroundColor(.white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [accentYellow.opacity(0.08), accentPurple.opacity(0.08)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(accentYellow.opacity(0.1), lineWidth: 1)
                    )
            )
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
        withAnimation(.easeInOut(duration: 0.3)) { isOpen = false }
    }
}
