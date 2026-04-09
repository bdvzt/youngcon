import Foundation

enum MapUITestFixture {
    static var launchEnvironment: [String: String] {
        [
            "youngcon_ui_test_map_fixture": encodedFixture,
        ]
    }

    private static var encodedFixture: String {
        let fixture = Fixture(
            floors: [
                FloorRecord(
                    id: "floor-1",
                    title: "1 Floor",
                    mapImageURL: URL(string: "https://example.com/maps/floor-1.png")!
                ),
                FloorRecord(
                    id: "floor-2",
                    title: "2 Floor",
                    mapImageURL: URL(string: "https://example.com/maps/floor-2.png")!
                ),
            ],
            zones: [
                ZoneRecord(
                    id: "zone-main-stage",
                    floorID: "floor-1",
                    title: "Main Stage",
                    description: "Главная сцена фестиваля",
                    cordX: 0.32,
                    cordY: 0.42,
                    icon: URL(string: "https://example.com/icons/main-stage.png")!,
                    color: "yellow"
                ),
                ZoneRecord(
                    id: "zone-career",
                    floorID: "floor-1",
                    title: "Career Zone",
                    description: "Зона карьерных консультаций",
                    cordX: 0.68,
                    cordY: 0.58,
                    icon: URL(string: "https://example.com/icons/career-zone.png")!,
                    color: "purple"
                ),
                ZoneRecord(
                    id: "zone-workshops",
                    floorID: "floor-2",
                    title: "Workshops",
                    description: "Практические воркшопы и мастер-классы",
                    cordX: 0.54,
                    cordY: 0.36,
                    icon: URL(string: "https://example.com/icons/workshops.png")!,
                    color: "pink"
                ),
            ]
        )

        do {
            let fixtureData = try JSONEncoder().encode(fixture)
            return fixtureData.base64EncodedString()
        } catch {
            fatalError("Failed to encode map UI test fixture: \(error)")
        }
    }
}

private extension MapUITestFixture {
    struct Fixture: Encodable {
        let floors: [FloorRecord]
        let zones: [ZoneRecord]
    }

    struct FloorRecord: Encodable {
        let id: String
        let title: String
        let mapImageURL: URL
    }

    struct ZoneRecord: Encodable {
        let id: String
        let floorID: String
        let title: String
        let description: String
        let cordX: Double
        let cordY: Double
        let icon: URL
        let color: String
    }
}
