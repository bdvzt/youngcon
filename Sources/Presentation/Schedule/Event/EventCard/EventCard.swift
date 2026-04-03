import Foundation
import SwiftUI

// MARK: - Mocks (данные для карточки события)

enum EventCardMocks {

    enum IDs {
        static let event = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        static let zone = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        static let speaker1 = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        static let speaker2 = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
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

    private var primarySpeaker: Speaker? { speakers.first }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 6) {
                Text(timeRangeText)
                    .font(.yandexSansText(.footnote, weight: .bold, monospacedDigits: false))
                    .foregroundStyle(Theme.eventTime)

                if isLive {
                    LivePulseDot()
                }

                Spacer(minLength: 8)
            }

            Text(event.title)
                .font(.yandexSansDisplay(.title3, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            if let speaker = primarySpeaker {
                HStack(alignment: .center, spacing: 12) {
                    SpeakerAvatar(url: speaker.photoURL)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(speaker.name)
                            .font(.yandexSansText(.callout, weight: .bold))
                            .foregroundStyle(.white)
                        Text(speaker.role)
                            .font(.yandexSansText(.caption))
                            .foregroundStyle(.white.opacity(0.55))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)

            HStack(alignment: .center, spacing: 12) {
                if let zone {
                    HStack(spacing: 6) {
                        Image(systemName: zone.iconName)
                            .font(.footnote.weight(.bold))
                            .foregroundStyle(zoneAccentColor(zone.color))
                        Text(zone.name)
                            .font(.yandexSansText(.footnote, weight: .bold))
                            .foregroundStyle(Theme.eventLocation)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                if showsStreamControl {
                    EventCardStreamButton()
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.eventCardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
    }

    private func zoneAccentColor(_ name: String) -> Color {
        switch name.lowercased() {
        case "indigo": return .indigo
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "mint": return .mint
        case "teal": return .teal
        case "cyan": return .cyan
        default: return Theme.tertiary
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
                    case .success(let image):
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
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            Theme.tertiary.opacity(0.35)
            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
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
    .background(Color(white: 0.12))
}

#Preview("Без зоны и эфира") {
    let ev = Event(
        id: EventCardMocks.IDs.event,
        title: "Короткий доклад",
        start: Date(),
        end: Date().addingTimeInterval(3600),
        speakerIDs: [EventCardMocks.IDs.speaker1],
        zoneID: nil,
        categoryCode: "talk",
        streamURL: nil
    )
    EventCard(event: ev, zone: nil, speakers: [EventCardMocks.speakers[0]])
        .padding()
        .background(Color(white: 0.12))
}
