import Foundation
import Observation

@MainActor
@Observable
final class MapViewModel {
    private let floorsRepository: FloorsRepositoryProtocol
    private let zoneRepository: ZoneRepositoryProtocol

    private(set) var floors: [Floor] = []
    private(set) var zonesByFloorID: [String: [Zone]] = [:]
    private(set) var selectedFloorID: String?
    private(set) var isLoading = false
    private(set) var loadError: String?

    var selectedFloor: Floor? {
        guard let selectedFloorID else {
            return floors.first
        }

        return floors.first { $0.id == selectedFloorID } ?? floors.first
    }

    var selectedFloorNumber: Int {
        guard let selectedFloorIndex else {
            return 1
        }

        return selectedFloorIndex + 1
    }

    var selectedZones: [Zone] {
        guard let selectedFloor else {
            return []
        }

        return zonesByFloorID[selectedFloor.id] ?? []
    }

    var canSelectNextFloor: Bool {
        guard let selectedFloorIndex else {
            return false
        }

        return selectedFloorIndex < floors.count - 1
    }

    var canSelectPreviousFloor: Bool {
        guard let selectedFloorIndex else {
            return false
        }

        return selectedFloorIndex > 0
    }

    private var selectedFloorIndex: Int? {
        guard let selectedFloor else {
            return nil
        }

        return floors.firstIndex { $0.id == selectedFloor.id }
    }

    init(
        floorsRepository: FloorsRepositoryProtocol,
        zoneRepository: ZoneRepositoryProtocol
    ) {
        self.floorsRepository = floorsRepository
        self.zoneRepository = zoneRepository
    }

    func load() async {
        guard !isLoading, floors.isEmpty else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let loadedFloors = try await floorsRepository.getFloors()
                .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
            let loadedZonesByFloorID = try await loadZonesByFloorID(for: loadedFloors)

            floors = loadedFloors
            zonesByFloorID = loadedZonesByFloorID
            selectedFloorID = selectedFloorID ?? loadedFloors.first?.id
        } catch {
            floors = []
            zonesByFloorID = [:]
            selectedFloorID = nil
            loadError = error.localizedDescription
        }
    }

    func selectNextFloor() {
        guard canSelectNextFloor, let selectedFloorIndex else {
            return
        }

        selectedFloorID = floors[selectedFloorIndex + 1].id
    }

    func selectPreviousFloor() {
        guard canSelectPreviousFloor, let selectedFloorIndex else {
            return
        }

        selectedFloorID = floors[selectedFloorIndex - 1].id
    }

    private func loadZonesByFloorID(for floors: [Floor]) async throws -> [String: [Zone]] {
        var zonesByFloorID: [String: [Zone]] = [:]

        try await withThrowingTaskGroup(of: (String, [Zone]).self) { group in
            for floor in floors {
                group.addTask { [zoneRepository] in
                    let zones = try await zoneRepository.getZones(floorID: floor.id)
                        .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
                    return (floor.id, zones)
                }
            }

            for try await (floorID, zones) in group {
                zonesByFloorID[floorID] = zones
            }
        }

        return zonesByFloorID
    }
}
