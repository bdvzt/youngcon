import SwiftUI

struct MapScreen: View {
    @StateObject private var viewModel: MapViewModel

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: container.makeMapViewModel())
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
    MapScreen(container: .preview)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(YoungConAsset.appBackground.swiftUIColor)
}
