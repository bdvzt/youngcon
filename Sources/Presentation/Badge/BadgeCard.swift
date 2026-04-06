import SwiftUI

struct BadgeCard: View {
    @Binding var isQRModalOpen: Bool

    var body: some View {
        GradientBorderCard(cornerRadius: 28) {
            ZStack {
                Circle()
                    .fill(AppColor.accentPurple)
                    .frame(width: 192, height: 192)
                    .blur(radius: 60)
                    .opacity(0.2)
                    .offset(x: 64, y: -64)
                Circle()
                    .fill(AppColor.accentPink)
                    .frame(width: 144, height: 144)
                    .blur(radius: 50)
                    .opacity(0.15)
                    .offset(x: -48, y: 48)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        nameBlock
                        Spacer()
                        qrButton
                    }
                    .padding(.bottom, 16)
                    footerRow
                }
                .padding(28)
            }
        }
    }

    private var nameBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Участник / 2026")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.25)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.2))
            Text("Алексей\nСмирнов")
                .font(.system(size: 30, weight: .black))
                .tracking(-0.5)
                .textCase(.uppercase)
                .foregroundColor(.white)
                .lineSpacing(2)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
            Text("Frontend Developer")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    private var qrButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isQRModalOpen = true
            }
        } label: {
            ZStack {
                CornerMarks(color: AppColor.accentYellow.opacity(0.5))
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 110, height: 110)
        }
        .buttonStyle(.plain)
    }

    private var footerRow: some View {
        HStack(spacing: 12) {
            Text("#YY-1024")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.25))
                .monospacedDigit()
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 12)
            Text("YoungCon")
                .font(.system(size: 10, weight: .black))
                .tracking(0.1)
                .textCase(.uppercase)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        colors: [AppColor.accentYellow, AppColor.accentPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
