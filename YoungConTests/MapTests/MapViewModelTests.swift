import Foundation
import XCTest
@testable import YoungCon

@MainActor
final class MapViewModelTests: XCTestCase {
    /// Проверяет, что до вызова `load()` view model находится в пустом начальном состоянии.
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

    /// Проверяет, что `load()` сортирует этажи и зоны, выбирает первый этаж и обновляет производное состояние.
    func testLoad_sortsFloorsAndZones_selectsFirstFloorAndUpdatesDerivedState() async {
        let firstFloor = MapViewModelTestFactory.makeFloor(id: "floor-b", title: "B Floor")
        let secondFloor = MapViewModelTestFactory.makeFloor(id: "floor-a", title: "A Floor")
        let thirdFloor = MapViewModelTestFactory.makeFloor(id: "floor-c", title: "C Floor")

        let floorsRepository = FloorsRepositorySpy(
            floors: [firstFloor, secondFloor, thirdFloor]
        )
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                secondFloor.id: [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-2",
                        floorID: secondFloor.id,
                        title: "Zulu"
                    ),
                    MapViewModelTestFactory.makeZone(
                        id: "zone-1",
                        floorID: secondFloor.id,
                        title: "Alpha"
                    ),
                ],
                firstFloor.id: [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-4",
                        floorID: firstFloor.id,
                        title: "Delta"
                    ),
                ],
                thirdFloor.id: [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-6",
                        floorID: thirdFloor.id,
                        title: "Gamma"
                    ),
                    MapViewModelTestFactory.makeZone(
                        id: "zone-5",
                        floorID: thirdFloor.id,
                        title: "Beta"
                    ),
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

    /// Проверяет, что выбор следующего этажа обновляет и выбранный этаж, и список видимых зон.
    func testSelectNextFloor_movesSelectionAndUpdatesSelectedZones() async {
        let firstFloor = MapViewModelTestFactory.makeFloor(id: "floor-2", title: "2 Floor")
        let secondFloor = MapViewModelTestFactory.makeFloor(id: "floor-1", title: "1 Floor")

        let floorsRepository = FloorsRepositorySpy(
            floors: [firstFloor, secondFloor]
        )
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                secondFloor.id: [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-a",
                        floorID: secondFloor.id,
                        title: "Alpha"
                    ),
                ],
                firstFloor.id: [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-b",
                        floorID: firstFloor.id,
                        title: "Beta"
                    ),
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

    /// Проверяет, что переключение этажей не выходит за границы первого и последнего этажа.
    func testFloorSelection_stopsAtCollectionBounds() async {
        let floors = [
            MapViewModelTestFactory.makeFloor(id: "floor-2", title: "2 Floor"),
            MapViewModelTestFactory.makeFloor(id: "floor-1", title: "1 Floor"),
        ]
        let floorsRepository = FloorsRepositorySpy(floors: floors)
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                "floor-1": [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-a",
                        floorID: "floor-1",
                        title: "Alpha"
                    ),
                ],
                "floor-2": [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-b",
                        floorID: "floor-2",
                        title: "Beta"
                    ),
                ],
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

    /// Проверяет, что ошибка загрузки этажей очищает состояние и сохраняет локализованное сообщение об ошибке.
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

    /// Проверяет, что ошибка загрузки зон очищает состояние и сохраняет локализованное сообщение об ошибке.
    func testLoad_whenZoneRequestFails_clearsStateAndStoresError() async {
        let firstFloor = MapViewModelTestFactory.makeFloor(id: "floor-1", title: "1 Floor")
        let secondFloor = MapViewModelTestFactory.makeFloor(id: "floor-2", title: "2 Floor")
        let floorsRepository = FloorsRepositorySpy(floors: [firstFloor, secondFloor])
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                firstFloor.id: [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-a",
                        floorID: firstFloor.id,
                        title: "Alpha"
                    ),
                ],
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

    /// Проверяет, что повторный вызов `load()` после успешной загрузки не запрашивает этажи и зоны заново.
    func testLoad_afterSuccessfulLoad_doesNotRefetchData() async {
        let floors = [
            MapViewModelTestFactory.makeFloor(id: "floor-2", title: "2 Floor"),
            MapViewModelTestFactory.makeFloor(id: "floor-1", title: "1 Floor"),
        ]
        let floorsRepository = FloorsRepositorySpy(floors: floors)
        let zoneRepository = ZoneRepositorySpy(
            zonesByFloorID: [
                "floor-1": [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-a",
                        floorID: "floor-1",
                        title: "Alpha"
                    ),
                ],
                "floor-2": [
                    MapViewModelTestFactory.makeZone(
                        id: "zone-b",
                        floorID: "floor-2",
                        title: "Beta"
                    ),
                ],
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
}

final class CachedFloorsRepositoryTests: XCTestCase {
    func testGetFloors_whenCacheExists_returnsCachedFloorsWithoutNetwork() async throws {
        let cacheStore = InMemoryScheduleCacheStore()
        try await cacheStore.save(
            [makeFloorDTO(id: "floor-cache", title: "Cached Floor")],
            for: CacheKey.Schedule.allFloors
        )
        let networkService = NetworkServiceSpy()
        networkService.stub(
            [makeFloorDTO(id: "floor-network", title: "Network Floor")],
            for: APIConstants.Floors.list
        )
        let repository = CachedFloorsRepository(
            networkService: networkService,
            cacheStore: cacheStore
        )

        let floors = try await repository.getFloors()

        XCTAssertEqual(floors.map(\.id), ["floor-cache"])
        let requestedPaths = networkService.recordedPaths()
        XCTAssertTrue(requestedPaths.isEmpty)
    }

    func testGetFloors_whenCacheMissing_loadsNetworkAndSavesCache() async throws {
        let cacheStore = InMemoryScheduleCacheStore()
        let networkService = NetworkServiceSpy()
        networkService.stub(
            [makeFloorDTO(id: "floor-network", title: "Network Floor")],
            for: APIConstants.Floors.list
        )
        let repository = CachedFloorsRepository(
            networkService: networkService,
            cacheStore: cacheStore
        )

        let floors = try await repository.getFloors()
        let cachedDTOs = try await cacheStore.load([FloorDTO].self, for: CacheKey.Schedule.allFloors)

        XCTAssertEqual(floors.map(\.id), ["floor-network"])
        XCTAssertEqual(cachedDTOs?.map(\.id), ["floor-network"])
        let requestedPaths = networkService.recordedPaths()
        XCTAssertEqual(requestedPaths, [APIConstants.Floors.list])
    }

    func testGetFloor_whenCacheExists_returnsCachedFloorWithoutNetwork() async throws {
        let cacheStore = InMemoryScheduleCacheStore()
        try await cacheStore.save(
            makeFloorDTO(id: "floor-cache", title: "Cached Floor"),
            for: CacheKey.Schedule.floor(floorID: "floor-cache")
        )
        let networkService = NetworkServiceSpy()
        networkService.stub(
            makeFloorDTO(id: "floor-cache", title: "Network Floor"),
            for: APIConstants.Floors.details("floor-cache")
        )
        let repository = CachedFloorsRepository(
            networkService: networkService,
            cacheStore: cacheStore
        )

        let floor = try await repository.getFloor(id: "floor-cache")

        XCTAssertEqual(floor.id, "floor-cache")
        XCTAssertEqual(floor.title, "Cached Floor")
        let requestedPaths = networkService.recordedPaths()
        XCTAssertTrue(requestedPaths.isEmpty)
    }

    private func makeFloorDTO(id: String, title: String) -> FloorDTO {
        FloorDTO(
            id: id,
            title: title,
            mapURL: "https://youngcon.test/\(id).png"
        )
    }
}

private actor InMemoryScheduleCacheStore: ScheduleCacheStoreProtocol {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var payloads: [String: Data] = [:]

    func save(_ value: some Encodable & Sendable, for key: String) async throws {
        payloads[key] = try encoder.encode(value)
    }

    func load<T: Decodable & Sendable>(_: T.Type, for key: String) async throws -> T? {
        guard let payload = payloads[key] else {
            return nil
        }
        return try decoder.decode(T.self, from: payload)
    }
}

private final class NetworkServiceSpy: NetworkServiceProtocol {
    private let lock = NSLock()
    private var decodableResponses: [String: any Decodable] = [:]
    private var requestedPaths: [String] = []

    func stub(_ value: some Decodable, for path: String) {
        lock.lock()
        defer { lock.unlock() }
        decodableResponses[path] = value
    }

    func request(_ endpoint: Endpoint) async throws {
        lock.lock()
        defer { lock.unlock() }
        requestedPaths.append(endpoint.path)
    }

    func requestDecodable<T: Decodable>(_ endpoint: Endpoint, as _: T.Type) async throws -> T {
        lock.lock()
        defer { lock.unlock() }
        requestedPaths.append(endpoint.path)

        guard let response = decodableResponses[endpoint.path] as? T else {
            throw MapViewModelTestError.missingStub
        }

        return response
    }

    func recordedPaths() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return requestedPaths
    }
}
