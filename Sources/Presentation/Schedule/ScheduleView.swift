import SwiftUI

struct ScheduleView: View {
    @State private var activeFilter: String = "Все"
    @State private var gradientOffset: CGFloat = 0

    private let background = YoungConAsset.appBackground.swiftUIColor
    private let yellow     = YoungConAsset.accentYellow.swiftUIColor
    private let purple     = YoungConAsset.accentPurple.swiftUIColor
    private let pink       = YoungConAsset.accentPink.swiftUIColor

    let filters = ["Все", "Избранное", "Live", "Лекция", "Интерактив", "Backend", "ML"]

    // MARK: - Filtering

    var filteredEvents: [ScheduleEntry] {
        switch activeFilter {
        case "Все":
            return scheduleData
        case "Live":
            return scheduleData.filter { $0.streamURL != nil }
        case "Избранное":
            // TODO: подключить FavoritesStore и фильтровать по избранным id
            return []
        default:
            return scheduleData.filter {
                $0.event.category.lowercased() == activeFilter.lowercased()
            }
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topLeading) {
            background.ignoresSafeArea()
            ambientGlows

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 52)
                    headerSection
                    ScheduleFilterBar(filters: filters, activeFilter: $activeFilter)
                    eventList
                    Color.clear.frame(height: 120)
                }
            }

            // Top fade overlay
            VStack(spacing: 0) {
                background.ignoresSafeArea(edges: .top)
                    .frame(height: 0)
                background.frame(height: 52)
                LinearGradient(
                    colors: [background, background.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)
                Spacer()
            }
            .zIndex(20)
            .allowsHitTesting(false)

            // Logo
            VStack(spacing: 0) {
                logoView
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                Spacer()
            }
            .zIndex(21)
            .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
    }

    // MARK: - Subviews

    private var logoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(RadialGradient(
                    colors: [yellow, .clear],
                    center: .center, startRadius: 5, endRadius: 40
                ))
                .frame(width: 80, height: 60)
                .blur(radius: 20)
                .opacity(0.35)
                .allowsHitTesting(false)

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: yellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ambientGlows: some View {
        ZStack {
            Circle()
                .fill(purple)
                .frame(width: 320, height: 320)
                .blur(radius: 100)
                .opacity(0.3)
                .offset(x: -130, y: -130)
                .allowsHitTesting(false)

            Circle()
                .fill(yellow)
                .frame(width: 288, height: 288)
                .blur(radius: 90)
                .opacity(0.2)
                .offset(x: 130, y: 300)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Расписание")
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .textCase(.uppercase)
                .foregroundStyle(
                    LinearGradient(
                        colors: [yellow, purple, pink, yellow],
                        startPoint: UnitPoint(x: gradientOffset * 0.5, y: 0),
                        endPoint: UnitPoint(x: gradientOffset * 0.5 + 1, y: 1)
                    )
                )

            Text("Программа мероприятий")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var eventList: some View {
        VStack(spacing: 14) {
            if filteredEvents.isEmpty {
                ScheduleEmptyState(activeFilter: activeFilter)
            } else {
                ForEach(filteredEvents) { entry in
                    EventCard(
                        event: entry.event,
                        zone: entry.zone,
                        speakers: entry.speakers,
                        streamURL: entry.streamURL
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    ScheduleView()
        .preferredColorScheme(.dark)
}
