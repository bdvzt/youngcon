import Foundation
import SwiftUI

struct EventCard: View {
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]
    /// streamURL передаётся снаружи — поля нет в модели Event
    var streamURL: URL?

    private var isLive: Bool {
        guard let start = event.startDate, let end = event.endDate else { return false }
        let now = Date()
        return now >= start && now <= end
    }

    private var showsStreamControl: Bool {
        isLive && streamURL != nil
    }

    private var timeRangeText: String {
        let start = event.startDate?.formatted(date: .omitted, time: .shortened) ?? "--:--"
        let end = event.endDate?.formatted(date: .omitted, time: .shortened) ?? "--:--"
        return "\(start) – \(end)"
    }

    private var primarySpeaker: Speaker? {
        speakers.first
    }

    // MARK: - Body

    var body: some View {
        cardStack
            .padding(22)
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

    // MARK: - Subviews

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

// MARK: - Previews

#Preview("Карточка") {
    EventCard(
        event: EventCardMocks.event,
        zone: EventCardMocks.zone,
        speakers: EventCardMocks.speakers,
        streamURL: URL(string: "https://example.com/stream")
    )
    .padding()
    .background(YoungConAsset.appBackground.swiftUIColor)
    .preferredColorScheme(.dark)
}

#Preview("Без зоны и эфира") {
    EventCard(
        event: EventCardMocks.shortEvent,
        zone: nil,
        speakers: [EventCardMocks.speakers[0]]
    )
    .padding()
    .background(YoungConAsset.appBackground.swiftUIColor)
    .preferredColorScheme(.dark)
}
