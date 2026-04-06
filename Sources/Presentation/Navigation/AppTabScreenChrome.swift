import SwiftUI

// MARK: - Logo

/// Плавающий логотип с жёлтым свечением — единый стиль вкладок.
struct AppScreenLogoBar: View {
    private let yellow = YoungConAsset.accentYellow.swiftUIColor

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(RadialGradient(
                    colors: [yellow, .clear],
                    center: .center, startRadius: 5, endRadius: 40
                ))
                .frame(width: 80, height: 60)
                .blur(radius: 20)
                .opacity(0.35)
                .allowsHitTesting(false)

            YoungConAsset.logo.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: yellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Top fade (scroll под логотипом)

/// Подложка под статус-бар и мягкий градиент, чтобы контент уходил под «шапку».
struct AppScreenTopFadeOverlay: View {
    let background: Color
    /// Прозрачная шапка (например, при полноэкранных модалках на вкладке бейджа).
    var isObscured: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            (isObscured ? Color.clear : background)
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)
            (isObscured ? Color.clear : background)
                .frame(height: 52)
            if !isObscured {
                LinearGradient(
                    colors: [background, background.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)
            }
            Spacer()
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Title block

/// Крупный градиентный заголовок и подзаголовок экрана вкладки.
struct AppScreenHeading: View {
    let title: String
    let subtitle: String

    @State private var gradientOffset: CGFloat = 0

    private let yellow = YoungConAsset.accentYellow.swiftUIColor
    private let purple = YoungConAsset.accentPurple.swiftUIColor
    private let pink = YoungConAsset.accentPink.swiftUIColor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
                .foregroundStyle(
                    LinearGradient(
                        colors: [yellow, purple, pink, yellow],
                        startPoint: UnitPoint(x: gradientOffset * 0.5, y: 0),
                        endPoint: UnitPoint(x: gradientOffset * 0.5 + 1, y: 1)
                    )
                )

            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
        .padding(.bottom, 12)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
    }
}
