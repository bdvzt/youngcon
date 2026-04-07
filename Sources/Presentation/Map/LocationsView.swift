import SwiftUI

struct LocationsView: View {
    @State private var floor: Int = 1
    @State private var focusedLocId: String?
    @State private var gradientOffset: CGFloat = 0

    private let appBackground = AppColor.appBackground

    private var currentLocations: [LocationModel] {
        mapLocationsData.filter { $0.floor == floor }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 52)
                    headerSection
                    mapSection
                    Color.clear.frame(height: 120)
                }
            }

            VStack(spacing: 0) {
                appBackground
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
                appBackground
                    .frame(height: 52)
                LinearGradient(
                    colors: [appBackground, appBackground.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)
                Spacer()
            }
            .zIndex(20)
            .allowsHitTesting(false)

            GeometryReader { geo in
                VStack(spacing: 0) {
                    logoView
                        .padding(.horizontal, 20)
                        .padding(.top, geo.safeAreaInsets.top + 8)
                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .top)
            .zIndex(21)
            .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
    }

    private var logoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(RadialGradient(
                    colors: [AppColor.accentYellow, .clear],
                    center: .center, startRadius: 5, endRadius: 40
                ))
                .frame(width: 80, height: 60)
                .blur(radius: 20)
                .opacity(0.35)
                .padding(-30)
                .allowsHitTesting(false)
            YoungConAsset.logo.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .shadow(color: AppColor.accentYellow.opacity(0.3), radius: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Локации")
                .font(.system(size: 48, weight: .black))
                .tracking(-1)
                .textCase(.uppercase)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColor.accentYellow,
                            AppColor.accentPurple,
                            AppColor.accentPink,
                            AppColor.accentYellow,
                        ],
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
        .padding(.top, 32)
        .padding(.bottom, 12)
    }

    private var mapSection: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppColor.cardBackground.opacity(0.6))
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
                            background: AppColor.appBackground,
                            yellow: AppColor.accentYellow,
                            purple: AppColor.accentPurple
                        ) {
                            focusedLocId = nil
                        }
                        .position(x: 32, y: height / 2)
                        flatMap(containerW: width, containerH: height)
                    }
                }
                .id(floor) // ← пересчитываем layout при смене этажа без лага
            }
            .frame(height: 460)

            // Овальчики локаций
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(currentLocations) { loc in
                        let isSelected = focusedLocId == loc.id
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                focusedLocId = isSelected ? nil : loc.id
                            }
                        } label: {
                            HStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? loc.color : loc.color.opacity(0.15))
                                        .frame(width: 22, height: 22)
                                    Image(systemName: loc.iconName)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(isSelected ? .black : loc.color)
                                }
                                Text(loc.title)
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.3)
                                    .foregroundColor(
                                        isSelected ? .black : .white.opacity(0.6)
                                    )
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        isSelected
                                            ? loc.color
                                            : Color.white.opacity(0.04)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                isSelected
                                                    ? loc.color.opacity(0.6)
                                                    : Color.white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(
                                color: isSelected ? loc.color.opacity(0.35) : .clear,
                                radius: 8, x: 0, y: 2
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 14)
            }
        }
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
                    background: AppColor.appBackground,
                    yellow: AppColor.accentYellow
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        focusedLocId = (focusedLocId == loc.id) ? nil : loc.id
                    }
                }
                .position(x: pinX, y: pinY)
            }

            if let focusedId = focusedLocId,
               let loc = currentLocations.first(where: { $0.id == focusedId })
            {
                let pinX = offsetX + mapW * loc.leftPercent
                let pinY = offsetY + mapH * loc.topPercent
                LocationPopupCard(
                    loc: loc,
                    background: AppColor.appBackground,
                    yellow: AppColor.accentYellow
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        focusedLocId = nil
                    }
                }
                .position(x: pinX, y: pinY - 90)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)))
                .zIndex(100)
            }
        }
        .position(x: mapX, y: mapY)
    }
}

#Preview {
    LocationsView()
        .preferredColorScheme(.dark)
}
