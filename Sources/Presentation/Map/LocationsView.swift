import SwiftUI

struct LocationsView: View {
    @State private var floor: Int = 1
    @State private var focusedLocId: String?
    @State private var gradientOffset: CGFloat = 0

    private let background = YoungConAsset.appBackground.swiftUIColor
    private let cardBg = YoungConAsset.cardBackground.swiftUIColor
    private let yellow = YoungConAsset.accentYellow.swiftUIColor
    private let purple = YoungConAsset.accentPurple.swiftUIColor
    private let pink = YoungConAsset.accentPink.swiftUIColor

    private var currentLocations: [LocationModal] {
        mapLocationsData.filter { $0.floor == floor }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            background.ignoresSafeArea()
            ambientGlows

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 52)
                    headerSection
                    mapSection
                    Color.clear.frame(height: 120)
                }
            }

            VStack {
                logoView.padding(.horizontal, 20)
                Spacer()
            }
            .zIndex(20)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
    }

    private var logoView: some View {
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

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: yellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ambientGlows: some View {
        ZStack {
            Circle()
                .fill(purple)
                .frame(width: 320, height: 320)
                .blur(radius: 100)
                .opacity(0.3)
                .offset(x: -130, y: -130)
                .allowsHitTesting(false)

            Circle()
                .fill(yellow)
                .frame(width: 288, height: 288)
                .blur(radius: 90)
                .opacity(0.2)
                .offset(x: 130, y: 300)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Локации")
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .textCase(.uppercase)
                .foregroundStyle(
                    LinearGradient(
                        colors: [yellow, purple, pink, yellow],
                        startPoint: UnitPoint(x: gradientOffset * 0.5, y: 0),
                        endPoint: UnitPoint(x: gradientOffset * 0.5 + 1, y: 1)
                    )
                )

            Text("Навигация по площадке")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var mapSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(cardBg.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

            GeometryReader { geo in
                let width = geo.size.width
                let height = geo.size.height
                ZStack {
                    LocationFloorSwitcher(
                        floor: $floor,
                        background: background, yellow: yellow, purple: purple
                    ) {
                        focusedLocId = nil
                    }
                    .position(x: 32, y: height / 2)

                    flatMap(containerW: width, containerH: height)
                }
            }
        }
        .frame(height: 520)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.25), value: floor)
        .animation(.easeInOut(duration: 0.2), value: focusedLocId)
    }

    @ViewBuilder
    private func flatMap(containerW: CGFloat, containerH: CGFloat) -> some View {
        let mapW: CGFloat = containerW * 0.73
        let mapH: CGFloat = containerH * 0.82
        let mapX: CGFloat = containerW / 2 + 28
        let mapY: CGFloat = containerH / 2
        let offsetX: CGFloat = mapX - mapW / 2
        let offsetY: CGFloat = mapY - mapH / 2

        ZStack {
            ForEach(currentLocations) { loc in
                let pinX = offsetX + mapW * loc.leftPercent
                let pinY = offsetY + mapH * loc.topPercent

                LocationPinView(
                    loc: loc,
                    isFocused: focusedLocId == loc.id,
                    focusedLocId: focusedLocId,
                    background: background,
                    yellow: yellow
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        focusedLocId = (focusedLocId == loc.id) ? nil : loc.id
                    }
                }
                .position(x: pinX, y: pinY)
            }
        }
        .position(x: mapX, y: mapY)
    }
}

#Preview {
    LocationsView()
        .preferredColorScheme(.dark)
}
