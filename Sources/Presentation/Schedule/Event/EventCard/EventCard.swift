import Foundation
import Kingfisher
import SafariServices
import SwiftUI

struct EventCard: View {
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]
    var streamURL: URL?
    @State private var isShowingStreamPlayer = false

    private var isLive: Bool {
        let start = event.startDate
        let end = event.endDate
        let now = Date()
        return now >= start && now <= end
    }

    private var showsStreamControl: Bool {
        streamURL != nil
    }

    private var timeRangeText: String {
        let start = event.startDate
        let end = event.endDate

        guard end >= start else {
            return "—"
        }

        let style = Date.IntervalFormatStyle(date: .omitted, time: .shortened)

        if end == start {
            return start.formatted(date: .omitted, time: .shortened)
        }

        return style.format(start ..< end)
    }

    private var primarySpeaker: Speaker? {
        speakers.first
    }

    private var cardGradient: LinearGradient {
        switch event.id {
        case "event-001":
            LinearGradient(
                colors: [AppColor.accentYellow, AppColor.accentPurple],
                startPoint: .top, endPoint: .bottom
            )
        case "event-002":
            LinearGradient(
                colors: [AppColor.accentPink, AppColor.accentPurple],
                startPoint: .top, endPoint: .bottom
            )
        case "event-003":
            LinearGradient(
                colors: [AppColor.accentYellow, AppColor.accentPink],
                startPoint: .top, endPoint: .bottom
            )
        default:
            LinearGradient(
                colors: [AppColor.accentPurple, AppColor.accentYellow],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(cardGradient)
                .frame(width: 3)
                .opacity(0.45)
                .padding(.vertical, 14)

            cardStack
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { cardBackground }
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        .sheet(isPresented: $isShowingStreamPlayer) {
            if let streamURL {
                SafariStreamPlayerView(url: streamURL)
                    .ignoresSafeArea()
            }
        }
    }

    private var cardStack: some View {
        VStack(alignment: .leading, spacing: 14) {
            scheduleRow
            titleBlock
            if let speaker = primarySpeaker {
                speakerRow(speaker)
            }
            separatorLine
            metaRow
        }
    }

    private var scheduleRow: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(timeRangeText)
                .font(.footnote)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(AppColor.gray500)
            if isLive {
                LivePulseDot()
            }
            Spacer(minLength: 8)
        }
    }

    private var titleBlock: some View {
        Text(event.title)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func speakerRow(_ speaker: Speaker) -> some View {
        HStack(alignment: .center, spacing: 12) {
            SpeakerAvatar(url: speaker.avatarImageURL)
            VStack(alignment: .leading, spacing: 2) {
                Text(speaker.fullName)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(speaker.job)
                    .font(.caption)
                    .foregroundStyle(AppColor.gray500)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(AppColor.gray500.opacity(0.35))
            .frame(height: 1)
    }

    private var metaRow: some View {
        HStack(alignment: .center, spacing: 12) {
            if let zone {
                HStack(spacing: 6) {
                    KFImage(zone.icon)
                        .resizable()
                        .scaledToFit()
                        .colorInvert()
                        .colorMultiply(AppColor.accentYellow)
                        .frame(width: 16, height: 16)
                        .padding(4)

                    Text(zone.title)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColor.gray500.opacity(0.7))
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            if showsStreamControl {
                Button {
                    isShowingStreamPlayer = true
                } label: {
                    EventCardStreamButton()
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.20))
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(AppColor.eventCardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppColor.gray500.opacity(0.22), lineWidth: 1)
            }
    }
}

private struct SafariStreamPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}
