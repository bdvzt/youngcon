import SwiftUI

struct BadgeCard: View {
    let user: UserProfile
    @Binding var isQRModalOpen: Bool

    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor
    private let accentPurple = YoungConAsset.accentPurple.swiftUIColor
    private let accentPink = YoungConAsset.accentPink.swiftUIColor
    private var qrPayload: String {
        user.qrCode.isEmpty ? user.id : user.qrCode
    }

    private var shortNumericID: String {
        let digits = user.id.filter(\.isNumber)
        let source = digits.isEmpty ? user.id : digits
        return String(source.prefix(4))
    }

    var body: some View {
        GradientBorderCard(cornerRadius: 28) {
            ZStack {
                Circle()
                    .fill(accentPurple)
                    .frame(width: 192, height: 192)
                    .blur(radius: 60)
                    .opacity(0.2)
                    .offset(x: 64, y: -64)
                Circle()
                    .fill(accentPink)
                    .frame(width: 144, height: 144)
                    .blur(radius: 50)
                    .opacity(0.15)
                    .offset(x: -48, y: 48)

                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        nameBlock
                        footerRow
                    }
                    Spacer(minLength: 0)
                    qrButton
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

            Text("\(user.firstName)\n\(user.lastName)")
                .font(.system(size: 30, weight: .black))
                .tracking(-0.5)
                .textCase(.uppercase)
                .foregroundColor(.white)
                .lineSpacing(2)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var qrButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isQRModalOpen = true
            }
        } label: {
            ZStack {
                CornerMarks(color: accentYellow.opacity(0.5))

                QRCodeView(text: qrPayload)
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
            Text("#YY-\(shortNumericID)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.25))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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
                        colors: [accentYellow, accentPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
