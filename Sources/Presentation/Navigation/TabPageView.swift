import SwiftUI

struct TabPageView: View {
    @Binding var activeTab: AppTab
    @Binding var previousTab: AppTab
    @Binding var isOverlayPresented: Bool
    let container: DependencyContainer
    let appViewModel: AppViewModel
    let tabs: [AppTab]

    var mapViewModel: MapViewModel?
    var scheduleViewModel: ScheduleViewModel?
    var badgeViewModel: BadgeViewModel?

    @Binding var isQRModalOpen: Bool
    @Binding var selectedSticker: Sticker?

    var onLogout: (() -> Void)?

    var body: some View {
        TabView(selection: $activeTab) {
            // Map
            Group {
                if let mapViewModel {
                    LocationsView(viewModel: mapViewModel)
                } else {
                    loadingPlaceholder
                }
            }
            .tag(AppTab.map)

            Group {
                if let scheduleViewModel {
                    ScheduleView(viewModel: scheduleViewModel)
                } else {
                    loadingPlaceholder
                }
            }
            .tag(AppTab.schedule)

            if tabs.contains(.badge) {
                Group {
                    if let badgeViewModel {
                        BadgeView(
                            viewModel: badgeViewModel,
                            isQRModalOpen: $isQRModalOpen,
                            selectedSticker: $selectedSticker,
                            onLogout: onLogout
                        )
                        .allowsHitTesting(!isOverlayPresented)
                    } else {
                        loadingPlaceholder
                    }
                }
                .tag(AppTab.badge)
            }

            if tabs.contains(.scanner) {
                OrganizerView(container: container, appViewModel: appViewModel)
                    .tag(AppTab.scanner)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.clear)
        .onChange(of: activeTab) { oldValue, newValue in
            guard oldValue != newValue else { return }
            previousTab = oldValue
        }
    }

    private var loadingPlaceholder: some View {
        ZStack {
            AppColor.appBackground.ignoresSafeArea()
            ProgressView().tint(.white.opacity(0.6))
        }
    }
}
