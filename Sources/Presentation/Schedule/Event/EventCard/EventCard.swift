import Foundation
import SwiftUI

// MARK: - Mocks (данные для карточки события)

enum EventCardMocks {
    enum IDs {
        static let event = Self.uuid("11111111-1111-1111-1111-111111111111")
        static let zone = Self.uuid("22222222-2222-2222-2222-222222222222")
        static let speaker1 = Self.uuid("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
        static let speaker2 = Self.uuid("BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")

        private static func uuid(_ string: String) -> UUID {
            guard let id = UUID(uuidString: string) else {
                preconditionFailure("Invalid mock UUID string: \(string)")
            }
            return id
        }
    }

    static let zone = Zone(
        id: IDs.zone,
        name: "Главная сцена",
        iconName: "theatermasks.fill",
        color: "indigo"
    )

    static let speakers: [Speaker] = [
        Speaker(
            id: IDs.speaker1,
            name: "Иван Петров",
            role: "Lead iOS Developer",
            bio: """
            Иван работает в Яндексе более 5 лет. Руководит разработкой мобильного приложения Яндекс.Карт.
            Спикер конференций Mobius и RIW. Увлекается SwiftUI и анимациями.
            """,
            photoURL: URL(string: "https://example.com/photos/ivan-petrov.jpg")
        ),
        Speaker(
            id: IDs.speaker2,
            name: "Мария Соколова",
            role: "Staff Engineer, Mobile Platform",
            bio: """
            Архитектура и производительность больших iOS-клиентов. Ранее — лид мобильной разработки в e-commerce.
            """,
            photoURL: URL(string: "https://example.com/photos/maria-sokolova.jpg")
        ),
    ]

    /// Интервал относительно «сейчас», чтобы в превью всегда были live-точка и кнопка трансляции.
    static var event: Event {
        let now = Date()
        return Event(
            id: IDs.event,
            title: "Разработка на Swift: современные подходы и best practices",
            start: now.addingTimeInterval(-30 * 60),
            end: now.addingTimeInterval(2 * 60 * 60),
            speakerIDs: [IDs.speaker1, IDs.speaker2],
            zoneID: IDs.zone,
            categoryCode: "development",
            streamURL: URL(string: "https://example.com/stream/2026/swift-talk")
        )
    }
}

// MARK: - EventCard

private enum EventCardPalette {
    static let timeText = Color(red: 208 / 255, green: 208 / 255, blue: 211 / 255)
    static let locationText = Color(red: 153 / 255, green: 161 / 255, blue: 175 / 255)
    static let speakerAvatar = Color(red: 53 / 255, green: 55 / 255, blue: 84 / 255)
}

struct EventCard: View {
    let event: Event
    let zone: Zone?
    let speakers: [Speaker]

    private var isLive: Bool {
        let now = Date()
        return now >= event.start && now <= event.end
    }

    private var showsStreamControl: Bool {
        isLive && event.streamURL != nil
    }

    private var timeRangeText: String {
        let start = event.start.formatted(date: .omitted, time: .shortened)
        let end = event.end.formatted(date: .omitted, time: .shortened)
        return "\(start) – \(end)"
    }

    private var primarySpeaker: Speaker? {
        speakers.first
    }

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
            SpeakerAvatar(url: speaker.photoURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(speaker.name)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(speaker.role)
                    .font(.caption)
                    .foregroundStyle(Color("Gray500"))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var separatorLine: some View {
        Rectangle()
            .fill(Color("Gray500").opacity(0.35))
            .frame(height: 1)
    }

    private var metaRow: some View {
        HStack(alignment: .center, spacing: 12) {
            if let zone {
                HStack(spacing: 6) {
                    Image(systemName: zone.iconName)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(zoneAccentColor(zone.color))
                    Text(zone.name)
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
                    .strokeBorder(Color("Gray500").opacity(0.22), lineWidth: 1)
            }
    }

    private func zoneAccentColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "pink", "red":
            Color("AccentPink")
        case "orange", "yellow":
            Color("AccentYellow")
        case "indigo", "blue", "purple", "green", "mint", "teal", "cyan":
            Color("AccentPurple")
        default:
            Color("AccentPurple")
        }
    }
}

// MARK: - Subviews

private struct LivePulseDot: View {
    @State private var dimmed = false

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 6, height: 6)
            .opacity(dimmed ? 0.38 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                    dimmed = true
                }
            }
    }
}

private struct SpeakerAvatar: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(EventCardPalette.speakerAvatar.opacity(0.55), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            EventCardPalette.speakerAvatar.opacity(0.35)
            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

#Preview("Карточка") {
    EventCard(
        event: EventCardMocks.event,
        zone: EventCardMocks.zone,
        speakers: EventCardMocks.speakers
    )
    .padding()
    .background(Color("AppBackground"))
    .preferredColorScheme(.dark)
}

#Preview("Без зоны и эфира") {
    let previewEvent = Event(
        id: EventCardMocks.IDs.event,
        title: "Короткий доклад",
        start: Date(),
        end: Date().addingTimeInterval(3600),
        speakerIDs: [EventCardMocks.IDs.speaker1],
        zoneID: nil,
        categoryCode: "talk",
        streamURL: nil
    )
    EventCard(event: previewEvent, zone: nil, speakers: [EventCardMocks.speakers[0]])
        .padding()
        .background(Color("AppBackground"))
        .preferredColorScheme(.dark)
}
