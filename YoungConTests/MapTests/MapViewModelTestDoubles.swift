import Foundation
@testable import YoungCon

actor FloorsRepositorySpy: FloorsRepositoryProtocol {
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

actor ZoneRepositorySpy: ZoneRepositoryProtocol {
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
