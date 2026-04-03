import SwiftUI

struct BadgeScreen: View {
    @StateObject private var viewModel: BadgeViewModel

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: container.makeBadgeViewModel())
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
    BadgeScreen(container: .preview)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(YoungConAsset.appBackground.swiftUIColor)
}
