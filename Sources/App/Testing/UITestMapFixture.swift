import Foundation
import SwiftUI

struct UITestMapFixture: Decodable {
    static let environmentKey = "youngcon_ui_test_map_fixture"

    let floors: [FloorRecord]
    let zones: [ZoneRecord]

    static func current(processInfo: ProcessInfo = .processInfo) -> UITestMapFixture? {
        guard
            let encodedFixture = processInfo.environment[environmentKey],
            let fixtureData = Data(base64Encoded: encodedFixture)
        else {
            return nil
        }

        return try? JSONDecoder().decode(UITestMapFixture.self, from: fixtureData)
    }

    @MainActor
    func makeViewModel() -> MapViewModel {
        let decodedFloors = floors.map(\.floor)
        let zonesByFloorID = Dictionary(grouping: zones.map(\.zone), by: \.floorID)

        return MapViewModel(
            preloadedFloors: decodedFloors,
            zonesByFloorID: zonesByFloorID
        )
    }
}

extension UITestMapFixture {
    struct FloorRecord: Decodable {
        let id: String
        let title: String
        let mapImageURL: URL

        var floor: Floor {
            Floor(id: id, title: title, mapImageURL: mapImageURL)
        }
    }

    struct ZoneRecord: Decodable {
        let id: String
        let floorID: String
        let title: String
        let description: String
        let cordX: Double?
        let cordY: Double?
        let icon: URL
        let color: ZoneColor

        var zone: Zone {
            Zone(
                id: id,
                floorID: floorID,
                title: title,
                description: description,
                cordX: cordX,
                cordY: cordY,
                icon: icon,
                color: color.value
            )
        }
    }

    enum ZoneColor: String, Decodable {
        case blue
        case pink
        case purple
        case yellow

        var value: Color {
            switch self {
            case .blue:
                .blue
            case .pink:
                .pink
            case .purple:
                .purple
            case .yellow:
                .yellow
            }
        }
    }
}
