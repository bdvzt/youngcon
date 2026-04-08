import SwiftUI

struct UITestMapRootView: View {
    private let fixture: UITestMapFixture?
    @State private var viewModel: MapViewModel?

    init(fixture: UITestMapFixture? = UITestMapFixture.current()) {
        self.fixture = fixture
    }

    var body: some View {
        Group {
            if let viewModel {
                LocationsView(viewModel: viewModel)
            } else if fixture != nil {
                ZStack {
                    AppColor.appBackground
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(.white.opacity(0.6))
                        .accessibilityIdentifier("map.bootstrap.loading")
                }
            } else {
                ZStack {
                    AppColor.appBackground
                        .ignoresSafeArea()

                    Text("UI test fixture is missing")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.6))
                        .accessibilityIdentifier("map.bootstrap.error")
                }
            }
        }
        .task {
            guard viewModel == nil, let fixture else { return }

            let model = await MainActor.run {
                fixture.makeViewModel()
            }

            await MainActor.run {
                viewModel = model
            }
        }
    }
}
