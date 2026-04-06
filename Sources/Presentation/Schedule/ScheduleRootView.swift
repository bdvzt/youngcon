import SwiftUI

/// Корень вкладки «Расписание»: отображает экран или плейсхолдер, пока `ScheduleViewModel` ещё не создан.
struct ScheduleRootView: View {
    var viewModel: ScheduleViewModel?

    var body: some View {
        if let viewModel {
            ScheduleView(viewModel: viewModel)
        } else {
            ScheduleLoadingPlaceholder()
        }
    }
}

struct ScheduleLoadingPlaceholder: View {
    var body: some View {
        ZStack {
            YoungConAsset.appBackground.swiftUIColor.ignoresSafeArea()
            ProgressView()
                .tint(.white.opacity(0.6))
        }
    }
}
