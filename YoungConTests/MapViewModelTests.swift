import SwiftUI
import XCTest
@testable import YoungCon

@MainActor
final class MapViewModelTests: XCTestCase {
    func testInitialState_beforeLoad_hasExpectedDefaults() {
        let viewModel = MapViewModel(
            floorsRepository: FloorsRepositorySpy(floors: []),
            zoneRepository: ZoneRepositorySpy(zonesByFloorID: [:])
        )

        XCTAssertTrue(viewModel.floors.isEmpty)
        XCTAssertTrue(viewModel.selectedZones.isEmpty)
        XCTAssertNil(viewModel.selectedFloor)
        XCTAssertEqual(viewModel.selectedFloorNumber, 1)
        XCTAssertFalse(viewModel.canSelectNextFloor)
        XCTAssertFalse(viewModel.canSelectPreviousFloor)
        XCTAssertNil(viewModel.loadError)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoad_sortsFloorsAndZones_selectsFirstFloorAndUpdatesDerivedState() async {
        let firstFloor = makeFloor(id: "floor-b", title: "B Floor")
        let secondFloor = makeFloor(id: "floor-a", title: "A Floor")
        let thirdFloor = makeFloor(id: "floor-c", title: "C Floor")

        let floorsRepository = FloorsRepositorySpy(
            floors: [firstFloor, secondFloor, thirdFloor]
        )
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                secondFloor.id: [
                    makeZone(id: "zone-2", floorID: secondFloor.id, title: "Zulu"),
                    makeZone(id: "zone-1", floorID: secondFloor.id, title: "Alpha"),
                ],
                firstFloor.id: [
                    makeZone(id: "zone-4", floorID: firstFloor.id, title: "Delta"),
                ],
                thirdFloor.id: [
                    makeZone(id: "zone-6", floorID: thirdFloor.id, title: "Gamma"),
                    makeZone(id: "zone-5", floorID: thirdFloor.id, title: "Beta"),
                ],
            ]
        )
        let viewModel = MapViewModel(
            floorsRepository: floorsRepository,
            zoneRepository: zoneRepository
        )

        await viewModel.load()

        XCTAssertEqual(viewModel.floors.map(\.title), ["A Floor", "B Floor", "C Floor"])
        XCTAssertEqual(viewModel.selectedFloor?.id, secondFloor.id)
        XCTAssertEqual(viewModel.selectedFloorNumber, 1)
        XCTAssertEqual(viewModel.selectedZones.map(\.title), ["Alpha", "Zulu"])
        XCTAssertTrue(viewModel.canSelectNextFloor)
        XCTAssertFalse(viewModel.canSelectPreviousFloor)
        XCTAssertNil(viewModel.loadError)
        XCTAssertFalse(viewModel.isLoading)

        let requestedFloorIDs = await zoneRepository.recordedFloorIDs()
        XCTAssertEqual(Set(requestedFloorIDs), Set([firstFloor.id, secondFloor.id, thirdFloor.id]))
    }

    func testSelectNextFloor_movesSelectionAndUpdatesSelectedZones() async {
        let firstFloor = makeFloor(id: "floor-2", title: "2 Floor")
        let secondFloor = makeFloor(id: "floor-1", title: "1 Floor")

        let floorsRepository = FloorsRepositorySpy(
            floors: [firstFloor, secondFloor]
        )
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                secondFloor.id: [
                    makeZone(id: "zone-a", floorID: secondFloor.id, title: "Alpha"),
                ],
                firstFloor.id: [
                    makeZone(id: "zone-b", floorID: firstFloor.id, title: "Beta"),
                ],
            ]
        )
        let viewModel = MapViewModel(
            floorsRepository: floorsRepository,
            zoneRepository: zoneRepository
        )

        await viewModel.load()
        viewModel.selectNextFloor()

        XCTAssertEqual(viewModel.selectedFloor?.id, firstFloor.id)
        XCTAssertEqual(viewModel.selectedFloorNumber, 2)
        XCTAssertEqual(viewModel.selectedZones.map(\.title), ["Beta"])
        XCTAssertFalse(viewModel.canSelectNextFloor)
        XCTAssertTrue(viewModel.canSelectPreviousFloor)
    }

    func testFloorSelection_stopsAtCollectionBounds() async {
        let floors = [
            makeFloor(id: "floor-2", title: "2 Floor"),
            makeFloor(id: "floor-1", title: "1 Floor"),
        ]
        let floorsRepository = FloorsRepositorySpy(floors: floors)
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                "floor-1": [makeZone(id: "zone-a", floorID: "floor-1", title: "Alpha")],
                "floor-2": [makeZone(id: "zone-b", floorID: "floor-2", title: "Beta")],
            ]
        )
        let viewModel = MapViewModel(
            floorsRepository: floorsRepository,
            zoneRepository: zoneRepository
        )

        await viewModel.load()

        XCTAssertEqual(viewModel.selectedFloor?.id, "floor-1")

        viewModel.selectPreviousFloor()
        XCTAssertEqual(viewModel.selectedFloor?.id, "floor-1")

        viewModel.selectNextFloor()
        XCTAssertEqual(viewModel.selectedFloor?.id, "floor-2")

        viewModel.selectNextFloor()
        XCTAssertEqual(viewModel.selectedFloor?.id, "floor-2")
    }

    func testLoad_whenFloorsRequestFails_clearsStateAndStoresError() async {
        let floorsRepository = FloorsRepositorySpy(
            floors: [],
            failureError: .floorsLoadFailed
        )
        let zoneRepository = ZoneRepositorySpy(zonesByFloorID: [:])
        let viewModel = MapViewModel(
            floorsRepository: floorsRepository,
            zoneRepository: zoneRepository
        )

        await viewModel.load()

        XCTAssertTrue(viewModel.floors.isEmpty)
        XCTAssertTrue(viewModel.selectedZones.isEmpty)
        XCTAssertNil(viewModel.selectedFloor)
        XCTAssertEqual(viewModel.selectedFloorNumber, 1)
        XCTAssertEqual(viewModel.loadError, MapViewModelTestError.floorsLoadFailed.localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoad_whenZoneRequestFails_clearsStateAndStoresError() async {
        let firstFloor = makeFloor(id: "floor-1", title: "1 Floor")
        let secondFloor = makeFloor(id: "floor-2", title: "2 Floor")
        let floorsRepository = FloorsRepositorySpy(floors: [firstFloor, secondFloor])
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                firstFloor.id: [makeZone(id: "zone-a", floorID: firstFloor.id, title: "Alpha")],
            ],
            failingFloorIDs: [secondFloor.id],
            failureError: .zoneLoadFailed
        )
        let viewModel = MapViewModel(
            floorsRepository: floorsRepository,
            zoneRepository: zoneRepository
        )

        await viewModel.load()

        XCTAssertTrue(viewModel.floors.isEmpty)
        XCTAssertTrue(viewModel.zonesByFloorID.isEmpty)
        XCTAssertNil(viewModel.selectedFloor)
        XCTAssertEqual(viewModel.selectedFloorNumber, 1)
        XCTAssertFalse(viewModel.canSelectNextFloor)
        XCTAssertFalse(viewModel.canSelectPreviousFloor)
        XCTAssertEqual(viewModel.loadError, MapViewModelTestError.zoneLoadFailed.localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoad_afterSuccessfulLoad_doesNotRefetchData() async {
        let floors = [
            makeFloor(id: "floor-2", title: "2 Floor"),
            makeFloor(id: "floor-1", title: "1 Floor"),
        ]
        let floorsRepository = FloorsRepositorySpy(floors: floors)
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                "floor-1": [makeZone(id: "zone-a", floorID: "floor-1", title: "Alpha")],
                "floor-2": [makeZone(id: "zone-b", floorID: "floor-2", title: "Beta")],
            ]
        )
        let viewModel = MapViewModel(
            floorsRepository: floorsRepository,
            zoneRepository: zoneRepository
        )

        await viewModel.load()
        await viewModel.load()

        let floorsCallCount = await floorsRepository.recordedGetFloorsCallCount()
        let zonesCallCount = await zoneRepository.recordedGetZonesCallCount()

        XCTAssertEqual(floorsCallCount, 1)
        XCTAssertEqual(zonesCallCount, 2)
        XCTAssertEqual(viewModel.floors.map(\.id), ["floor-1", "floor-2"])
    }

    private func makeFloor(id: String, title: String) -> Floor {
        Floor(
            id: id,
            title: title,
            mapImageURL: URL(string: "https://example.com/\(id).png")!
        )
    }

    private func makeZone(id: String, floorID: String, title: String) -> Zone {
        Zone(
            id: id,
            floorID: floorID,
            title: title,
            description: "\(title) description",
            cordX: 0.5,
            cordY: 0.5,
            icon: URL(string: "https://example.com/\(id).png")!,
            color: .blue
        )
    }
}

private actor FloorsRepositorySpy: FloorsRepositoryProtocol {
    private let floors: [Floor]
    private let failureError: MapViewModelTestError?
    private var getFloorsCallCount = 0

    init(floors: [Floor], failureError: MapViewModelTestError? = nil) {
        self.floors = floors
        self.failureError = failureError
    }

    func getFloor(id: String) async throws -> Floor {
        if let floor = floors.first(where: { $0.id == id }) {
            return floor
        }
        throw MapViewModelTestError.missingStub
    }

    func getFloors() async throws -> [Floor] {
        getFloorsCallCount += 1

        if let failureError {
            throw failureError
        }

        return floors
    }

    func recordedGetFloorsCallCount() -> Int {
        getFloorsCallCount
    }
}

private actor ZoneRepositorySpy: ZoneRepositoryProtocol {
    private let zonesByFloorID: [String: [Zone]]
    private let failingFloorIDs: Set<String>
    private let failureError: MapViewModelTestError?
    private var requestedFloorIDs: [String] = []

    init(
        zonesByFloorID: [String: [Zone]],
        failingFloorIDs: Set<String> = [],
        failureError: MapViewModelTestError? = nil
    ) {
        self.zonesByFloorID = zonesByFloorID
        self.failingFloorIDs = failingFloorIDs
        self.failureError = failureError
    }

    func getZone(zoneID: String) async throws -> Zone {
        for zones in zonesByFloorID.values {
            if let zone = zones.first(where: { $0.id == zoneID }) {
                return zone
            }
        }

        throw MapViewModelTestError.missingStub
    }

    func getZones(floorID: String) async throws -> [Zone] {
        requestedFloorIDs.append(floorID)

        if failingFloorIDs.contains(floorID), let failureError {
            throw failureError
        }

        return zonesByFloorID[floorID] ?? []
    }

    func recordedFloorIDs() -> [String] {
        requestedFloorIDs
    }

    func recordedGetZonesCallCount() -> Int {
        requestedFloorIDs.count
    }
}

private enum MapViewModelTestError: LocalizedError {
    case missingStub
    case floorsLoadFailed
    case zoneLoadFailed

    var errorDescription: String? {
        switch self {
        case .missingStub:
            "Missing test stub"
        case .floorsLoadFailed:
            "Floors load failed"
        case .zoneLoadFailed:
            "Zone load failed"
        }
    }
}
