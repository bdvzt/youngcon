import SwiftUI

struct GradientProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.04))
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [AppColor.accentYellow, AppColor.accentPurple, AppColor.accentPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * max(0, min(1, progress)))
            }
        }
        .frame(height: 6)
        .clipShape(Capsule())
    }
}
