import SwiftUI

struct GradientBorderCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    private let cardBg = YoungConAsset.cardBackground.swiftUIColor
    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor
    private let accentPurple = YoungConAsset.accentPurple.swiftUIColor

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(cardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accentYellow.opacity(0.15),
                                .clear,
                                .clear,
                                accentPurple.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
