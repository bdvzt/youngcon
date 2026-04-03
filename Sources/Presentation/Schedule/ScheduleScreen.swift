import SwiftUI

struct ScheduleScreen: View {
    @StateObject private var viewModel: ScheduleViewModel

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: container.makeScheduleViewModel())
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.screenTitle)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
        }
        .task { await viewModel.onAppear() }
    }
}

#Preview {
    ScheduleScreen(container: .preview)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(YoungConAsset.appBackground.swiftUIColor)
}
