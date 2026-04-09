import Kingfisher
import Observation
import SwiftUI

struct LocationsView: View {
    @Bindable var viewModel: MapViewModel

    @State private var focusedZoneID: String?
    @State private var gradientOffset: CGFloat = 0

    var hasFixedHeader: Bool = false

    private let appBackground = AppColor.appBackground

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: hasFixedHeader ? 60 : 52)
                    headerSection
                    mapSection
                    Color.clear.frame(height: 120)
                }
            }
            .scrollClipDisabled(true)
            .accessibilityIdentifier("map.screen")
        }
        .task {
            await viewModel.load()
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 1
            }
        }
        .task {
            await viewModel.load()
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }

    private var topOverlay: some View {
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
                .accessibilityIdentifier("map.header.title")

            Text("Навигация по площадке")
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.25))
                .accessibilityIdentifier("map.header.subtitle")
        }
        .padding(.horizontal, 20)
        .padding(.top, hasFixedHeader ? 20 : 32)
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
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white.opacity(0.6))
                                .accessibilityIdentifier("map.loading")
                        } else if let loadError = viewModel.loadError {
                            Text(loadError)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.55))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .accessibilityIdentifier("map.error")
                        } else if let floor = viewModel.selectedFloor {
                            LocationFloorSwitcher(
                                floorNumber: viewModel.selectedFloorNumber,
                                canSelectNextFloor: viewModel.canSelectNextFloor,
                                canSelectPreviousFloor: viewModel.canSelectPreviousFloor,
                                background: AppColor.appBackground,
                                yellow: AppColor.accentYellow,
                                purple: AppColor.accentPurple,
                                onNextFloor: {
                                    viewModel.selectNextFloor()
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        focusedZoneID = nil
                                    }
                                },
                                onPreviousFloor: {
                                    viewModel.selectPreviousFloor()
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        focusedZoneID = nil
                                    }
                                }
                            )
                            .position(x: 32, y: height / 2)
                            .zIndex(2)

                            flatMap(
                                containerW: width,
                                containerH: height,
                                floor: floor,
                                zones: viewModel.selectedZones
                            )
                        } else {
                            Text("Карта пока недоступна")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.55))
                                .multilineTextAlignment(.center)
                                .accessibilityIdentifier("map.empty")
                        }
                    }
                }
                .id(viewModel.selectedFloor?.id)
            }
            .frame(height: 460)
            .padding(.horizontal, 20)

            zoneSelector
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedFloor?.id)
    }

    @ViewBuilder
    private var zoneSelector: some View {
        if !viewModel.selectedZones.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.selectedZones) { zone in
                        let isSelected = focusedZoneID == zone.id
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                focusedZoneID = isSelected ? nil : zone.id
                            }
                        } label: {
                            HStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? zone.color : zone.color.opacity(0.15))
                                        .frame(width: 22, height: 22)
                                    ZoneIconImage(url: zone.icon, placeholderFontSize: 10)
                                        .frame(width: 10, height: 10)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityIdentifier("map.zoneChip.icon.\(zone.id)")
                                .accessibilityLabel(zone.title)
                                Text(zone.title)
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
                                            ? zone.color
                                            : Color.white.opacity(0.04)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                isSelected
                                                    ? zone.color.opacity(0.6)
                                                    : Color.white.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .shadow(
                                color: isSelected ? zone.color.opacity(0.35) : .clear,
                                radius: 8, x: 0, y: 2
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                        .accessibilityIdentifier("map.zoneChip.\(zone.id)")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
            }
            .accessibilityIdentifier("map.zoneSelector")
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.06),
                        .init(color: .black, location: 0.94),
                        .init(color: .clear, location: 1),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }

    @ViewBuilder
    private func flatMap(containerW: CGFloat, containerH: CGFloat, floor: Floor, zones: [Zone]) -> some View {
        let mapH: CGFloat = containerH * 0.90
        let mapW: CGFloat = mapH * Self.mapAspectRatio
        let mapX: CGFloat = containerW / 2 + 28
        let mapY: CGFloat = containerH / 2

        ZStack {
            mapImage(floor)

            ForEach(zones) { zone in
                if let coordinate = coordinate(for: zone) {
                    let pinX = mapW * coordinate.x
                    let pinY = mapH * coordinate.y
                    LocationPinView(
                        zone: zone,
                        isFocused: focusedZoneID == zone.id,
                        focusedZoneID: focusedZoneID,
                        background: AppColor.appBackground,
                        yellow: AppColor.accentYellow
                    ) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            focusedZoneID = (focusedZoneID == zone.id) ? nil : zone.id
                        }
                    }
                    .position(x: pinX, y: pinY)
                }
            }

            if let focusedZoneID,
               let zone = zones.first(where: { $0.id == focusedZoneID }),
               let coordinate = coordinate(for: zone)
            {
                let pinX = mapW * coordinate.x
                let pinY = mapH * coordinate.y
                LocationPopupCard(
                    zone: zone,
                    background: AppColor.appBackground,
                    yellow: AppColor.accentYellow
                ) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.focusedZoneID = nil
                    }
                }
                .position(x: pinX, y: pinY - 90)
                .zIndex(100)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
        .frame(width: mapW, height: mapH)
        .position(x: mapX, y: mapY)
    }

    private func mapImage(_ floor: Floor) -> some View {
        KFImage(floor.mapImageURL)
            .placeholder {
                mapImageFallback
                    .overlay {
                        ProgressView()
                            .tint(.white.opacity(0.6))
                    }
            }
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.35), radius: 18, y: 12)
    }

    private var mapImageFallback: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        AppColor.accentPurple.opacity(0.26),
                        AppColor.cardBackground.opacity(0.9),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    // MARK: - Helpers

    private func normalizedCoordinate(_ value: Double) -> CGFloat {
        min(max(CGFloat(value), 0), 1)
    }

    private func coordinate(for zone: Zone) -> CGPoint? {
        guard let cordX = zone.cordX, let cordY = zone.cordY else {
            return nil
        }
        return CGPoint(
            x: normalizedCoordinate(cordX),
            y: normalizedCoordinate(cordY)
        )
    }

    private static let mapAspectRatio: CGFloat = 501 / 981
}

#Preview {
    LocationsPreviewHost()
        .preferredColorScheme(.dark)
}

private struct LocationsPreviewHost: View {
    @State private var viewModel: MapViewModel?
    @Environment(\.dependencyContainer) private var container

    var body: some View {
        Group {
            if let viewModel {
                LocationsView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                let model = MapViewModel(
                    floorsRepository: container.floorsRepository,
                    zoneRepository: container.zoneRepository
                )
                viewModel = model
                await model.load()
            }
        }
    }
}
