import Observation
import SwiftUI

struct ScheduleView: View {
    @Bindable var viewModel: ScheduleViewModel

    @State private var activeFilter: String = "Все"
    @State private var gradientOffset: CGFloat = 0

    let filters = ["Все", "Избранное", "Live", "Лекция", "Интерактив", "Backend", "ML"]

    private var filteredEntries: [ScheduleEntry] {
        switch activeFilter {
        case "Все":
            viewModel.entries
        case "Live":
            viewModel.entries.filter { $0.streamURL != nil }
        case "Избранное":
            []
        default:
            viewModel.entries.filter {
                $0.event.category.lowercased() == activeFilter.lowercased()
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 52)
                    headerSection
                    ScheduleFilterBar(filters: filters, activeFilter: $activeFilter)
                    eventList
                    Color.clear.frame(height: 120)
                }
            }

            VStack(spacing: 0) {
                AppColor.appBackground.ignoresSafeArea(edges: .top)
                    .frame(height: 0)
                AppColor.appBackground.frame(height: 52)
                LinearGradient(
                    colors: [AppColor.appBackground, AppColor.appBackground.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)
                Spacer()
            }
            .zIndex(20)
            .allowsHitTesting(false)

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
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
    }

    private var logoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(RadialGradient(
                    colors: [AppColor.accentYellow, .clear],
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
                .shadow(color: AppColor.accentYellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Расписание")
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.accentYellow, AppColor.accentPurple, AppColor.accentPink, AppColor.accentYellow],
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
        .padding(.top, 32)
        .padding(.bottom, 12)
    }

    private var eventList: some View {
        VStack(spacing: 14) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let loadError = viewModel.loadError {
                Text(loadError)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if filteredEntries.isEmpty {
                ScheduleEmptyState(activeFilter: activeFilter)
            } else {
                ForEach(filteredEntries) { entry in
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

#Preview {
    SchedulePreviewHost()
        .preferredColorScheme(.dark)
}

private struct SchedulePreviewHost: View {
    @State private var viewModel: ScheduleViewModel?
    @Environment(\.dependencyContainer) private var container

    var body: some View {
        Group {
            if let viewModel {
                ScheduleView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                let model = ScheduleViewModel(
                    festivalsRepository: container.festivalsRepository,
                    eventsRepository: container.eventsRepository,
                    zoneRepository: container.zoneRepository,
                    speakersRepository: container.speakersRepository
                )
                viewModel = model
                await model.load()
            }
        }
    }
}
