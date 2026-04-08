import SafariServices
import SwiftUI

struct EventDetailedCard: View {
    @State private var isFavorite = false
    @State private var isShowingStreamPlayer = false
    @Environment(\.dismiss) private var dismiss

    private let model: EventDetailedCardModel
    private let streamURL: URL?
    private let cardCornerRadius: CGFloat = 34

    init(event: Event, zone: Zone?, speaker: Speaker, streamURL: URL?) {
        self.streamURL = streamURL
        model = EventDetailedCardModel(
            title: event.title,
            time: Self.formatTimeRange(start: event.startDate, end: event.endDate),
            location: zone?.title ?? "TBD",
            description: event.description ?? "",
            speakerName: speaker.fullName,
            speakerRole: speaker.job,
            primaryActionTitle: streamURL != nil ? "Смотреть трансляцию" : "Подробнее",
            speaker: speaker
        )
    }

    private static func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    var body: some View {
        ZStack {
            AppColor.navBackground
                .ignoresSafeArea()

            cardContent
                .padding()
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingStreamPlayer) {
            if let streamURL {
                SafariStreamPlayerView(url: streamURL)
                    .ignoresSafeArea()
            }
        }
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
                .fill(AppColor.appBackground)
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
                    .fill(AppColor.navBackground)
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
                .foregroundColor(AppColor.accentPurple)

            Text(model.location)
                .foregroundColor(.white.opacity(0.62))
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.navBackground)
        )
    }

    private var speakerCard: some View {
        NavigationLink(destination: SpeakerCardView(speaker: model.speaker)) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColor.gray700)
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
                        .foregroundColor(AppColor.accentYellow)
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
                    .fill(AppColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button(action: {
                isShowingStreamPlayer = true
            }, label: {
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
                        .fill(AppColor.accentYellow)
                )
                .shadow(
                    color: AppColor.accentYellow.opacity(0.28),
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
                    .foregroundColor(isFavorite ? AppColor.accentYellow : .white.opacity(0.55))
                    .frame(width: 64, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColor.gray700)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isFavorite ? AppColor.accentYellow.opacity(0.32) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var closeButton: some View {
        Button(action: {
            dismiss()
        }, label: {
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

private struct SafariStreamPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}
