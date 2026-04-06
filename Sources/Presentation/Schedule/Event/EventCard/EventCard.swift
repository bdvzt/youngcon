import Foundation
import SwiftUI

struct EventCard: View {
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]
    var streamURL: URL?

    private var isLive: Bool {
        guard let start = event.startDate, let end = event.endDate else { return false }
        let now = Date()
        return now >= start && now <= end
    }

    private var showsStreamControl: Bool {
        streamURL != nil
    }

    private var timeRangeText: String {
        guard let start = event.startDate, let end = event.endDate, end >= start else {
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
                colors: [YoungConAsset.accentYellow.swiftUIColor, YoungConAsset.accentPurple.swiftUIColor],
                startPoint: .top, endPoint: .bottom
            )
        case "event-002":
            LinearGradient(
                colors: [YoungConAsset.accentPink.swiftUIColor, YoungConAsset.accentPurple.swiftUIColor],
                startPoint: .top, endPoint: .bottom
            )
        case "event-003":
            LinearGradient(
                colors: [YoungConAsset.accentYellow.swiftUIColor, YoungConAsset.accentPink.swiftUIColor],
                startPoint: .top, endPoint: .bottom
            )
        default:
            LinearGradient(
                colors: [YoungConAsset.accentPurple.swiftUIColor, YoungConAsset.accentYellow.swiftUIColor],
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
                .foregroundStyle(EventCardPalette.timeText)
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
                    .foregroundStyle(YoungConAsset.gray500.swiftUIColor)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(YoungConAsset.gray500.swiftUIColor.opacity(0.35))
            .frame(height: 1)
    }

    private var metaRow: some View {
        HStack(alignment: .center, spacing: 12) {
            if let zone {
                HStack(spacing: 6) {
                    Image(systemName: zone.icon)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(zoneAccentColor(zone.color))
                    Text(zone.title)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(EventCardPalette.locationText)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            if showsStreamControl {
                EventCardStreamButton()
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
            .fill(Color(red: 21 / 255, green: 22 / 255, blue: 33 / 255))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(YoungConAsset.gray500.swiftUIColor.opacity(0.22), lineWidth: 1)
            }
    }

    private func zoneAccentColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "pink", "red":
            YoungConAsset.accentPink.swiftUIColor
        case "orange", "yellow":
            YoungConAsset.accentYellow.swiftUIColor
        case "indigo", "blue", "purple", "green", "mint", "teal", "cyan":
            YoungConAsset.accentPurple.swiftUIColor
        default:
            YoungConAsset.accentPurple.swiftUIColor
        }
    }
}
