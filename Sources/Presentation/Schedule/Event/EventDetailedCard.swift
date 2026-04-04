import SwiftUI

struct EventDetailedCard: View {
    @State private var isFavorite = false

    private let model: EventDetailedCardModel
    private let cardCornerRadius: CGFloat = 34

    init(model: EventDetailedCardModel = .mock) {
        self.model = model
    }

    var body: some View {
        ZStack {
            YoungConAsset.navBackground.swiftUIColor
                .ignoresSafeArea()

            cardContent
                .padding()
        }
        .preferredColorScheme(.dark)
    }

    private var cardContent: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 18) {
                timeChip

                Text(model.title)
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .black))
                    .lineSpacing(-2)
                    .fixedSize(horizontal: false, vertical: true)

                locationChip

                Text(model.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.74))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)

                speakerCard
                    .padding(.top, 2)

                actionRow
                    .padding(.top, 8)
            }
            .padding(.horizontal, 26)
            .padding(.top, 34)
            .padding(.bottom, 24)

            closeButton
                .padding(.top, 20)
                .padding(.trailing, 18)
        }
        .frame(maxWidth: 420, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(YoungConAsset.appBackground.swiftUIColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 30, y: 16)
    }

    private var timeChip: some View {
        Text(model.time)
            .foregroundColor(.white.opacity(0.92))
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(YoungConAsset.navBackground.swiftUIColor)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private var locationChip: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(YoungConAsset.accentPurple.swiftUIColor)

            Text(model.location)
                .foregroundColor(.white.opacity(0.62))
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(YoungConAsset.navBackground.swiftUIColor)
        )
    }

    private var speakerCard: some View {
        Button(action: {}, label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(YoungConAsset.gray700.swiftUIColor)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )

                    Image(systemName: "person")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white.opacity(0.58))
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 6) {
                    Text(model.speakerName)
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .black))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(model.speakerRole)
                        .foregroundColor(YoungConAsset.accentYellow.swiftUIColor)
                        .font(.system(size: 14, weight: .black))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white.opacity(0.48))
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.04))
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(YoungConAsset.cardBackground.swiftUIColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button(action: {}, label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))

                    Text(model.primaryActionTitle)
                        .font(.system(size: 16, weight: .black))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(YoungConAsset.accentYellow.swiftUIColor)
                )
                .shadow(
                    color: YoungConAsset.accentYellow.swiftUIColor.opacity(0.28),
                    radius: 18,
                    y: 6
                )
            })
            .buttonStyle(.plain)

            Button {
                isFavorite.toggle()
            } label: {
                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isFavorite ? YoungConAsset.accentYellow.swiftUIColor : .white.opacity(0.55))
                    .frame(width: 64, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(YoungConAsset.gray700.swiftUIColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isFavorite ? YoungConAsset.accentYellow.swiftUIColor.opacity(0.32) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var closeButton: some View {
        Button(action: {}, label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.05))
                )
        })
        .buttonStyle(.plain)
    }
}

#Preview {
    EventDetailedCard()
}
