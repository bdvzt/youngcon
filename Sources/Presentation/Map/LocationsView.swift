import SwiftUI

struct LocationsView: View {
    @State private var floor: Int = 1
    @State private var focusedLocId: String?

    private let background = YoungConAsset.appBackground.swiftUIColor
    private let cardBg = YoungConAsset.cardBackground.swiftUIColor
    private let yellow = YoungConAsset.accentYellow.swiftUIColor
    private let purple = YoungConAsset.accentPurple.swiftUIColor

    private var currentLocations: [LocationModel] {
        mapLocationsData.filter { $0.floor == floor }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            background.ignoresSafeArea()
            ambientGlows

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 52)
                    AppScreenHeading(title: "Локации", subtitle: "Навигация по площадке")
                    mapSection
                    Color.clear.frame(height: 120)
                }
            }

            AppScreenTopFadeOverlay(background: background)
                .zIndex(20)

            VStack(spacing: 0) {
                AppScreenLogoBar()
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                Spacer()
            }
            .zIndex(21)
            .allowsHitTesting(false)
        }
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
