import SwiftUI

struct GradientBorderCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColor.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColor.accentYellow.opacity(0.15),
                                .clear,
                                .clear,
                                AppColor.accentPurple.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
