import SwiftUI

// MARK: - GradientBorderCard

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
                                Color.clear,
                                Color.clear,
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

// MARK: - CornerMarks

struct CornerMarks: View {
    let color: Color
    let length: CGFloat = 14
    let width: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: length))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: length, y: 0))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width - length, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: length))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height - length))
                    path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    path.addLine(to: CGPoint(x: length, y: geo.size.height))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width - length, y: geo.size.height))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - length))
                }
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
            }
        }
    }
}

// MARK: - GradientProgressBar

struct GradientProgressBar: View {
    let progress: Double

    private let accentYellow = YoungConAsset.accentYellow.swiftUIColor
    private let accentPurple = YoungConAsset.accentPurple.swiftUIColor
    private let accentPink = YoungConAsset.accentPink.swiftUIColor

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.04))
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accentYellow, accentPurple, accentPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 6)
        .clipShape(Capsule())
    }
}
