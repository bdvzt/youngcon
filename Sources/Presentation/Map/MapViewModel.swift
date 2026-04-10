import Foundation
import Observation

@MainActor
@Observable
final class MapViewModel {
    private let floorsRepository: FloorsRepositoryProtocol?
    private let zoneRepository: ZoneRepositoryProtocol?
    
    private var pollingTask: Task<Void, Never>?
    
    private(set) var floors: [Floor] = []
    private(set) var zonesByFloorID: [String: [Zone]] = [:]
    private(set) var selectedFloorID: String?
    
    private(set) var isLoading = false
    private(set) var isInitialLoading = false
    private(set) var isRefreshing = false
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
    
    init(
        preloadedFloors: [Floor],
        zonesByFloorID: [String: [Zone]],
        selectedFloorID: String? = nil
    ) {
        floorsRepository = nil
        zoneRepository = nil
        floors = Self.sortedFloors(preloadedFloors)
        self.zonesByFloorID = Self.sortedZonesByFloorID(zonesByFloorID)
        self.selectedFloorID = selectedFloorID ?? floors.first?.id
    }
    
    func load() async {
        guard floors.isEmpty else { return }
        await load(policy: .cacheFirst, mode: .initial)
    }
    
    func refreshFromNetworkIfNeeded() async {
        await load(policy: .networkFirst, mode: .refresh)
    }
    
    func startPolling(every seconds: TimeInterval = 60) {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--uitesting-map") {
            return
        }
#endif
        stopPolling()
        
        pollingTask = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                await refreshFromNetworkIfNeeded()
                
                do {
                    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                } catch {
                    break
                }
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
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
    
    private func load(
        policy: CachePolicy,
        mode: LoadMode
    ) async {
        guard let floorsRepository, let zoneRepository else { return }
        guard !isLoading else { return }
        
        isLoading = true
        applyLoadingState(for: mode, isActive: true)
        defer {
            isLoading = false
            applyLoadingState(for: mode, isActive: false)
        }
        
        do {
            let newState = try await buildMapState(
                policy: policy,
                floorsRepository: floorsRepository,
                zoneRepository: zoneRepository
            )
            
            let floorsChanged = newState.floors != floors
            let zonesChanged = newState.zonesByFloorID != zonesByFloorID
            let selectedFloorChanged = newState.selectedFloorID != selectedFloorID
            
            if floorsChanged {
                floors = newState.floors
            }
            
            if zonesChanged {
                zonesByFloorID = newState.zonesByFloorID
            }
            
            if selectedFloorChanged {
                selectedFloorID = newState.selectedFloorID
            }
            
            loadError = nil
        } catch {
            loadError = error.localizedDescription
            
            if floors.isEmpty {
                zonesByFloorID = [:]
                selectedFloorID = nil
            }
        }
    }
    
    private func applyLoadingState(for mode: LoadMode, isActive: Bool) {
        switch mode {
        case .initial:
            isInitialLoading = isActive
        case .refresh:
            isRefreshing = isActive
        }
    }
    
    private func buildMapState(
        policy: CachePolicy,
        floorsRepository: FloorsRepositoryProtocol,
        zoneRepository: ZoneRepositoryProtocol
    ) async throws -> MapState {
        let loadedFloors = try await Self.sortedFloors(
            floorsRepository.getFloors(policy: policy)
        )
        
        let loadedZonesByFloorID = try await loadZonesByFloorID(
            for: loadedFloors,
            zoneRepository: zoneRepository,
            policy: policy
        )
        
        let resolvedSelectedFloorID = resolveSelectedFloorID(from: loadedFloors)
        
        return MapState(
            floors: loadedFloors,
            zonesByFloorID: loadedZonesByFloorID,
            selectedFloorID: resolvedSelectedFloorID
        )
    }
    
    private func resolveSelectedFloorID(from floors: [Floor]) -> String? {
        guard !floors.isEmpty else { return nil }
        
        if let selectedFloorID,
           floors.contains(where: { $0.id == selectedFloorID })
        {
            return selectedFloorID
        }
        
        return floors.first?.id
    }
    
    private func loadZonesByFloorID(
        for floors: [Floor],
        zoneRepository: ZoneRepositoryProtocol,
        policy: CachePolicy
    ) async throws -> [String: [Zone]] {
        var zonesByFloorID: [String: [Zone]] = [:]
        
        try await withThrowingTaskGroup(of: (String, [Zone]).self) { group in
            for floor in floors {
                group.addTask { [zoneRepository] in
                    let zones = try await Self.sortedZones(
                        zoneRepository.getZones(floorID: floor.id, policy: policy)
                    )
                    return (floor.id, zones)
                }
            }
            
            for try await (floorID, zones) in group {
                zonesByFloorID[floorID] = zones
            }
        }
        
        return zonesByFloorID
    }
    
    private static func sortedFloors(_ floors: [Floor]) -> [Floor] {
        floors.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
    
    private static func sortedZones(_ zones: [Zone]) -> [Zone] {
        zones.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
    
    private static func sortedZonesByFloorID(_ zonesByFloorID: [String: [Zone]]) -> [String: [Zone]] {
        Dictionary(
            uniqueKeysWithValues: zonesByFloorID.map { floorID, zones in
                (floorID, sortedZones(zones))
            }
        )
    }
}

private struct MapState: Equatable {
    let floors: [Floor]
    let zonesByFloorID: [String: [Zone]]
    let selectedFloorID: String?
}

private extension MapViewModel {
    enum LoadMode {
        case initial
        case refresh
    }
}
