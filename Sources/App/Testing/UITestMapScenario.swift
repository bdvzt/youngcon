import Foundation
import SwiftUI

enum UITestLaunchScenario {
    case none
    case map

    static var current: UITestLaunchScenario {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("--uitesting-map") {
            return .map
        }

        return .none
    }
}

struct UITestMapRootView: View {
    @State private var viewModel: MapViewModel?

    var body: some View {
        Group {
            if let viewModel {
                LocationsView(viewModel: viewModel)
            } else {
                ZStack {
                    AppColor.appBackground.ignoresSafeArea()
                    ProgressView()
                        .tint(.white.opacity(0.6))
                        .accessibilityIdentifier("map.bootstrap.loading")
                }
            }
        }
        .task {
            guard viewModel == nil else { return }

            let model = await MainActor.run {
                MapViewModel(
                    floorsRepository: UITestMapFloorsRepository(),
                    zoneRepository: UITestMapZoneRepository()
                )
            }

            await MainActor.run {
                viewModel = model
            }

            await model.load()
        }
    }
}

private final class UITestMapFloorsRepository: FloorsRepositoryProtocol {
    private let floors: [Floor] = [
        Floor(
            id: "floor-1",
            title: "1 Floor",
            mapImageURL: URL(string: "https://example.com/maps/floor-1.png")!
        ),
        Floor(
            id: "floor-2",
            title: "2 Floor",
            mapImageURL: URL(string: "https://example.com/maps/floor-2.png")!
        ),
    ]

    func getFloor(id: String) async throws -> Floor {
        guard let floor = floors.first(where: { $0.id == id }) else {
            throw UITestMapError.missingData
        }

        return floor
    }

    func getFloors() async throws -> [Floor] {
        floors
    }
}

private final class UITestMapZoneRepository: ZoneRepositoryProtocol {
    private let zonesByFloorID: [String: [Zone]] = [
        "floor-1": [
            Zone(
                id: "zone-main-stage",
                floorID: "floor-1",
                title: "Main Stage",
                description: "Главная сцена фестиваля",
                cordX: 0.32,
                cordY: 0.42,
                icon: URL(string: "https://example.com/icons/main-stage.png")!,
                color: .yellow
            ),
            Zone(
                id: "zone-career",
                floorID: "floor-1",
                title: "Career Zone",
                description: "Зона карьерных консультаций",
                cordX: 0.68,
                cordY: 0.58,
                icon: URL(string: "https://example.com/icons/career-zone.png")!,
                color: .purple
            ),
        ],
        "floor-2": [
            Zone(
                id: "zone-workshops",
                floorID: "floor-2",
                title: "Workshops",
                description: "Практические воркшопы и мастер-классы",
                cordX: 0.54,
                cordY: 0.36,
                icon: URL(string: "https://example.com/icons/workshops.png")!,
                color: .pink
            ),
        ],
    ]

    func getZone(zoneID: String) async throws -> Zone {
        for zones in zonesByFloorID.values {
            if let zone = zones.first(where: { $0.id == zoneID }) {
                return zone
            }
        }

        throw UITestMapError.missingData
    }

    func getZones(floorID: String) async throws -> [Zone] {
        zonesByFloorID[floorID] ?? []
    }
}

private enum UITestMapError: LocalizedError {
    case missingData

    var errorDescription: String? {
        switch self {
        case .missingData:
            "Missing UI test data"
        }
    }
}
