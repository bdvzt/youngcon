import SwiftUI

struct TabPageView: View {
    let tab: AppTab
    @Binding var isOverlayPresented: Bool

    var body: some View {
        ZStack {
            YoungConAsset.appBackground.swiftUIColor.ignoresSafeArea()

            switch tab {
            case .schedule:
                VStack(spacing: 16) {
                    Text(tab.label)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                }

            case .map:
                VStack(spacing: 16) {
                    Text(tab.label)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                }

            case .badge:
                VStack(spacing: 16) {
                    Text("Бейдж")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
