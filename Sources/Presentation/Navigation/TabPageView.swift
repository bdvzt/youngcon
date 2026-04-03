import SwiftUI

struct TabPageView: View {
    let tab: AppTab
    @Binding var isOverlayPresented: Bool

    @Environment(\.dependencyContainer) private var dependencyContainer

    var body: some View {
        ZStack {
            YoungConAsset.appBackground.swiftUIColor.ignoresSafeArea()

            switch tab {
            case .schedule:
                ScheduleScreen(container: dependencyContainer)
            case .map:
                MapScreen(container: dependencyContainer)
            case .badge:
                BadgeScreen(container: dependencyContainer)
            }
        }
    }
}
