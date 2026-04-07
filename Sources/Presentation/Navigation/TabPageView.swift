import SwiftUI

struct TabPageView: View {
    @Binding var activeTab: AppTab
    @Binding var previousTab: AppTab
    @Binding var isOverlayPresented: Bool
    let container: DependencyContainer

    var scheduleViewModel: ScheduleViewModel?

    var body: some View {
        TabView(selection: $activeTab) {
            LocationsView()
                .tag(AppTab.map)

            Group {
                if let scheduleViewModel {
                    ScheduleView(viewModel: scheduleViewModel)
                } else {
                    ZStack {
                        AppColor.appBackground.ignoresSafeArea()
                        ProgressView()
                            .tint(.white.opacity(0.6))
                    }
                }
            }
            .tag(AppTab.schedule)

            BadgeView(container: container, isOverlayPresented: $isOverlayPresented)
                .tag(AppTab.badge)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.clear)
        .onChange(of: activeTab) { oldValue, newValue in
            guard oldValue != newValue else { return }
            previousTab = oldValue
        }
    }
}
