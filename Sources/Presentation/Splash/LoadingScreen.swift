import SwiftUI

struct LoadingScreen: View {
    @Binding var isLoading: Bool

    @State private var isPulsing = false
    @State private var glowRotation: Double = 0.0

    private let backgroundColor = Color("AppBackground")
    private let accentColor = Color("AccentYellow")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 24) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        accentColor.opacity(0.6),
                                        Color.cyan.opacity(0.4),
                                        accentColor.opacity(0.6),
                                        Color.cyan.opacity(0.4),
                                        accentColor.opacity(0.6),
                                    ]),
                                    center: .center
                                )
                            )
                            .frame(width: 180, height: 180)
                            .blur(radius: 40)
                            .rotationEffect(.degrees(glowRotation))
                    )
                    .shadow(color: accentColor.opacity(0.15), radius: 10)
                    .scaleEffect(isPulsing ? 1.15 : 0.85)
            }
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true

                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    glowRotation = 360.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeOut(duration: 0.8)) {
                        isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    LoadingScreen(isLoading: .constant(true))
        .preferredColorScheme(.dark)
}
