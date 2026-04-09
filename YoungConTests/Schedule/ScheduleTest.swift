import XCTest
@testable import YoungCon

// MARK: - Вспомогательные типы

enum NetworkError: Error {
    case generic
}

// MARK: - Моки репозиториев

final class MockFestivalsRepository: FestivalsRepositoryProtocol {
    var shouldFail = false
    var mockFestival = Festival(
        id: "fest-1",
        title: "Тестовый фестиваль",
        description: "Описание",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400)
    )

    private(set) var getLastFestivalCallCount = 0

    func getLastFestival(policy _: CachePolicy = .cacheFirst) async throws -> Festival {
        getLastFestivalCallCount += 1
        if shouldFail { throw NetworkError.generic }
        return mockFestival
    }
}

final class MockEventsRepository: EventsRepositoryProtocol {
    var shouldFail = false
    var mockEvents: [Event] = []
    var mockSpeakerEvents: [String: [Event]] = [:]

    private(set) var getEventsCallCount = 0
    private(set) var getSpeakerEventsCallCount = 0

    func getEvents(festivalID _: String, policy _: CachePolicy = .cacheFirst) async throws -> [Event] {
        getEventsCallCount += 1
        if shouldFail { throw NetworkError.generic }
        return mockEvents
    }

    func getEvent(eventID _: String, policy _: CachePolicy = .cacheFirst) async throws -> Event {
        fatalError("не используется в тестах")
    }

    func getZoneEvents(zoneID _: String) async throws -> [Event] {
        fatalError("не используется в тестах")
    }

    func getSpeakerEvents(speakerID: String) async throws -> [Event] {
        getSpeakerEventsCallCount += 1
        if shouldFail { throw NetworkError.generic }
        return mockSpeakerEvents[speakerID] ?? []
    }

    func likeEvent(eventID _: String) async throws -> LikeEventResponse {
        fatalError("не используется в тестах")
    }
}

final class MockZoneRepository: ZoneRepositoryProtocol {
    var shouldFail = false
    var mockZones: [String: Zone] = [:]

    private(set) var getZoneCallCount = 0

    func getZone(zoneID: String, policy _: CachePolicy = .cacheFirst) async throws -> Zone {
        getZoneCallCount += 1
        if shouldFail { throw NetworkError.generic }
        guard let zone = mockZones[zoneID] else {
            throw NetworkError.generic
        }
        return zone
    }

    func getZones(floorID _: String, policy _: CachePolicy = .cacheFirst) async throws -> [Zone] {
        fatalError("не используется в тестах")
    }
}

final class MockSpeakersRepository: SpeakersRepositoryProtocol {
    var shouldFail = false
    var mockSpeakers: [Speaker] = []

    private(set) var getAllSpeakersCallCount = 0

    func getSpeaker(speakerID _: String, policy _: CachePolicy = .cacheFirst) async throws -> Speaker {
        fatalError("не используется в тестах")
    }

    func getAllSpeakers(policy _: CachePolicy = .cacheFirst) async throws -> [Speaker] {
        getAllSpeakersCallCount += 1
        if shouldFail { throw NetworkError.generic }
        return mockSpeakers
    }
}

// MARK: - Unit-тесты ScheduleViewModel

@MainActor
final class ScheduleViewModelUnitTests: XCTestCase {
    private var festivalsRepo: MockFestivalsRepository!
    private var eventsRepo: MockEventsRepository!
    private var zonesRepo: MockZoneRepository!
    private var speakersRepo: MockSpeakersRepository!
    private var usersRepo: MockUsersRepository!
    private var viewModel: ScheduleViewModel!

    override func setUp() {
        super.setUp()
        festivalsRepo = MockFestivalsRepository()
        eventsRepo = MockEventsRepository()
        zonesRepo = MockZoneRepository()
        speakersRepo = MockSpeakersRepository()
        viewModel = ScheduleViewModel(
            festivalsRepository: festivalsRepo,
            eventsRepository: eventsRepo,
            zoneRepository: zonesRepo,
            speakersRepository: speakersRepo,
            usersRepository: usersRepo
        )
    }

    override func tearDown() {
        festivalsRepo = nil
        eventsRepo = nil
        zonesRepo = nil
        speakersRepo = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Успешный сценарий

    func testLoadData_Success_EntriesPopulatedCorrectly() async throws {
        let event1 = Event(
            id: "ev-1", title: "Лекция 1", description: "", startDate: Date(), endDate: Date(),
            category: "Лекция", zoneID: "zone-1", festivalID: "fest-1", streamURL: nil
        )
        let event2 = Event(
            id: "ev-2", title: "Мастер-класс", description: "", startDate: Date(), endDate: Date(),
            category: "Интерактив", zoneID: "zone-2", festivalID: "fest-1", streamURL: URL(string: "https://stream.com")
        )
        eventsRepo.mockEvents = [event1, event2]

        let zone1 = try Zone(id: "zone-1", floorID: "floor-1", title: "Зал A", description: "", cordX: 0, cordY: 0, icon: XCTUnwrap(URL(string: "https://icon.com")), color: .yellow)
        let zone2 = try Zone(id: "zone-2", floorID: "floor-1", title: "Зал B", description: "", cordX: 0, cordY: 0, icon: XCTUnwrap(URL(string: "https://icon.com")), color: .blue)
        zonesRepo.mockZones = ["zone-1": zone1, "zone-2": zone2]

        let speaker1 = Speaker(id: "sp-1", fullName: "Иван Иванов", job: "Эксперт", bio: "Био", avatarImageURL: nil)
        let speaker2 = Speaker(id: "sp-2", fullName: "Петр Петров", job: "Ведущий", bio: "Био", avatarImageURL: nil)
        speakersRepo.mockSpeakers = [speaker1, speaker2]

        eventsRepo.mockSpeakerEvents = [
            "sp-1": [event1],
            "sp-2": [event2],
        ]

        // Act
        await viewModel.load()

        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.loadError)
        XCTAssertEqual(viewModel.entries.count, 2)

        let entry1 = viewModel.entries.first { $0.event.id == "ev-1" }
        let entry2 = viewModel.entries.first { $0.event.id == "ev-2" }

        XCTAssertNotNil(entry1)
        XCTAssertNotNil(entry2)

        XCTAssertEqual(entry1?.zone?.id, "zone-1")
        XCTAssertEqual(entry2?.zone?.id, "zone-2")

        XCTAssertEqual(entry1?.speakers.count, 1)
        XCTAssertEqual(entry1?.speakers.first?.id, "sp-1")
        XCTAssertEqual(entry2?.speakers.count, 1)
        XCTAssertEqual(entry2?.speakers.first?.id, "sp-2")

        XCTAssertNil(entry1?.streamURL)
        XCTAssertEqual(entry2?.streamURL, URL(string: "https://stream.com"))

        XCTAssertEqual(festivalsRepo.getLastFestivalCallCount, 1)
        XCTAssertEqual(eventsRepo.getEventsCallCount, 1)
        XCTAssertEqual(zonesRepo.getZoneCallCount, 2)
        XCTAssertEqual(speakersRepo.getAllSpeakersCallCount, 1)
        XCTAssertEqual(eventsRepo.getSpeakerEventsCallCount, 2)
    }

    // MARK: - Ошибка получения фестиваля

    func testLoadData_FestivalError_StopsLoadingAndSetsError() async {
        festivalsRepo.shouldFail = true

        await viewModel.load()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.loadError)
        XCTAssertTrue(viewModel.entries.isEmpty)
        XCTAssertEqual(eventsRepo.getEventsCallCount, 0)
    }

    // MARK: - Ошибка получения событий

    func testLoadData_EventsError_StopsLoadingAndSetsError() async {
        eventsRepo.shouldFail = true

        await viewModel.load()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.loadError)
        XCTAssertTrue(viewModel.entries.isEmpty)
        XCTAssertEqual(zonesRepo.getZoneCallCount, 0)
        XCTAssertEqual(speakersRepo.getAllSpeakersCallCount, 0)
    }

    // MARK: - Ошибка загрузки зоны (не прерывает общую загрузку)

    func testLoadData_ZoneError_ContinuesWithoutZone() async {
        let event = Event(
            id: "ev-1", title: "Лекция", description: "", startDate: Date(), endDate: Date(),
            category: "Лекция", zoneID: "zone-bad", festivalID: "fest-1", streamURL: nil
        )
        eventsRepo.mockEvents = [event]
        zonesRepo.shouldFail = true

        let speaker = Speaker(id: "sp-1", fullName: "Иван", job: "Job", bio: "", avatarImageURL: nil)
        speakersRepo.mockSpeakers = [speaker]
        eventsRepo.mockSpeakerEvents = ["sp-1": [event]]

        await viewModel.load()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.loadError)
        XCTAssertEqual(viewModel.entries.count, 1)

        let entry = viewModel.entries.first
        XCTAssertNil(entry?.zone)
        XCTAssertEqual(entry?.speakers.count, 1)
        XCTAssertEqual(zonesRepo.getZoneCallCount, 1)
    }

    // MARK: - Ошибка загрузки спикеров (не прерывает загрузку, но спикеры отсутствуют)

    func testLoadData_SpeakersError_EntriesHaveNoSpeakers() async throws {
        let event = Event(
            id: "ev-1", title: "Лекция", description: "", startDate: Date(), endDate: Date(),
            category: "Лекция", zoneID: "zone-1", festivalID: "fest-1", streamURL: nil
        )
        eventsRepo.mockEvents = [event]

        let zone = try Zone(id: "zone-1", floorID: "floor-1", title: "Зал", description: "", cordX: 0, cordY: 0, icon: XCTUnwrap(URL(string: "https://icon.com")), color: .yellow)
        zonesRepo.mockZones = ["zone-1": zone]

        speakersRepo.shouldFail = true

        await viewModel.load()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.loadError)
        XCTAssertEqual(viewModel.entries.count, 1)

        let entry = viewModel.entries.first
        XCTAssertNotNil(entry?.zone)
        XCTAssertTrue(entry?.speakers.isEmpty ?? true)
        XCTAssertEqual(speakersRepo.getAllSpeakersCallCount, 1)
        XCTAssertEqual(eventsRepo.getSpeakerEventsCallCount, 0)
    }

    // MARK: - Защита от конкурентных вызовов load()

    func testLoadData_ConcurrentCalls_OnlyOneExecution() async {
        festivalsRepo.shouldFail = false
        eventsRepo.mockEvents = []

        async let load1: Void = viewModel.load()
        async let load2: Void = viewModel.load()

        _ = await (load1, load2)

        XCTAssertEqual(festivalsRepo.getLastFestivalCallCount, 1)
        XCTAssertEqual(eventsRepo.getEventsCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Проверка флага isLoading во время загрузки

    func testLoadData_LoadingFlagSetCorrectly() async {
        festivalsRepo.shouldFail = false
        eventsRepo.mockEvents = []

        let task = Task {
            await viewModel.load()
        }

        let start = Date()
        while !viewModel.isLoading, Date().timeIntervalSince(start) < 0.5 {
            await Task.yield()
        }
        XCTAssertTrue(viewModel.isLoading)

        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }
}
