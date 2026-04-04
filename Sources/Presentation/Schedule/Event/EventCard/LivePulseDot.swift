import SwiftUI

struct LivePulseDot: View {
    @State private var dimmed = false

    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 6, height: 6)
            .opacity(dimmed ? 0.38 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                    dimmed = true
                }
            }
    }
}
