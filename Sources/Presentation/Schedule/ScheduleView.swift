import Observation
import SwiftUI

struct ScheduleView: View {
    @Bindable var viewModel: ScheduleViewModel

    @State private var activeFilter: ScheduleFilter = .all

    private let background = YoungConAsset.appBackground.swiftUIColor
    private let yellow = YoungConAsset.accentYellow.swiftUIColor
    private let purple = YoungConAsset.accentPurple.swiftUIColor

    private var filters: [ScheduleFilter] {
        ScheduleFilter.allCases
    }

    private var scheduleEntries: [ScheduleEntry] {
        viewModel.entries
    }

    private var isScheduleLoading: Bool {
        viewModel.isLoading
    }

    var filteredEvents: [ScheduleEntry] {
        scheduleEntries.filter { activeFilter.matches($0) }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            background.ignoresSafeArea()
            ambientGlows

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 52)
                    AppScreenHeading(title: "Расписание", subtitle: "Программа мероприятий")
                    ScheduleFilterBar(filters: filters, activeFilter: $activeFilter)
                    eventList
                    Color.clear.frame(height: 120)
                }
            }

            AppScreenTopFadeOverlay(background: background)
                .zIndex(20)

            VStack(spacing: 0) {
                AppScreenLogoBar()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                Spacer()
            }
            .zIndex(21)
            .allowsHitTesting(false)
        }
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

    private var eventList: some View {
        VStack(spacing: 14) {
            if isScheduleLoading {
                ProgressView()
                    .tint(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let error = viewModel.loadError {
                Text(error.userFacingMessage)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if filteredEvents.isEmpty {
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

#Preview {
    SchedulePreviewHost()
        .preferredColorScheme(.dark)
}

private struct SchedulePreviewHost: View {
    @State private var viewModel: ScheduleViewModel?
    private let dependencyContainer = DependencyContainer.live()

    var body: some View {
        Group {
            if let viewModel {
                ScheduleView(viewModel: viewModel)
            } else {
                ScheduleLoadingPlaceholder()
            }
        }
        .environment(\.dependencyContainer, dependencyContainer)
        .task {
            let model = dependencyContainer.makeScheduleViewModel()
            viewModel = model
            await model.load()
        }
    }
}
