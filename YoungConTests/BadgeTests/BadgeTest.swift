import XCTest
@testable import YoungCon

// MARK: - Mocks

final class MockUsersRepository: UsersRepositoryProtocol {
    var shouldFailProfile = false
    var shouldFailProgress = false
    var delayTime: TimeInterval?

    private(set) var getMyProfileCallCount = 0
    private(set) var getUserAchievementsCallCount = 0

    var mockProfile: UserProfile = .init(
        id: "test-id-123",
        firstName: "Тест",
        lastName: "Тестов",
        email: "test@test.com",
        qrCode: "QR_TEST",
        major: .ios,
        role: .client
    )

    var mockUnlockedAchievements: [Achievement] = []

    func getMyProfile() async throws -> UserProfile {
        getMyProfileCallCount += 1
        if let delay = delayTime { try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) }
        if shouldFailProfile { throw NetworkError.generic }
        return mockProfile
    }

    func getUserAchievements(userID _: String) async throws -> [Achievement] {
        getUserAchievementsCallCount += 1
        if shouldFailProgress { throw NetworkError.generic }
        return mockUnlockedAchievements
    }

    func getUserLikedEvents(userID _: String) async throws -> [Event] {
        []
    }

    func assignAchievement(qrCode _: String, achievementId _: String) async throws -> AssignResult {
        .init(userId: "test", achievementId: "test", assignedNow: false)
    }

    func resolveQR(_: String) async throws -> ResolvedUser {
        .init(userId: "1", firstName: "", lastName: "", qrCode: "")
    }
}

final class MockAchievementsRepository: AchievementsRepositoryProtocol {
    var shouldFail = false

    private(set) var getAchievementsCallCount = 0

    var mockAchievements: [Achievement] = [
        Achievement(id: "ach-1", name: "Тест 1", description: "Desc 1", icon: URL(string: "https://test.com/1.png"), color: .white),
        Achievement(id: "ach-2", name: "Тест 2", description: "Desc 2", icon: URL(string: "https://test.com/2.png"), color: .black),
    ]

    func getAchievements() async throws -> [Achievement] {
        getAchievementsCallCount += 1
        if shouldFail { throw NetworkError.generic }
        return mockAchievements
    }
}

// MARK: - Tests

@MainActor
final class BadgeViewModelUnitTests: XCTestCase {
    private var mockUsersRepo: MockUsersRepository!
    private var mockAchievementsRepo: MockAchievementsRepository!
    private var viewModel: BadgeViewModel!

    override func setUp() {
        super.setUp()
        mockUsersRepo = MockUsersRepository()
        mockAchievementsRepo = MockAchievementsRepository()
        viewModel = BadgeViewModel(
            usersRepository: mockUsersRepo,
            achievementsRepository: mockAchievementsRepo
        )
    }

    override func tearDown() {
        mockUsersRepo = nil
        mockAchievementsRepo = nil
        viewModel = nil
        super.tearDown()
    }

    func testLoadData_Success_StateUpdatesCorrectly() async {
        mockUsersRepo.mockUnlockedAchievements = [
            Achievement(id: "ach-1", name: "", description: "", icon: nil, color: .clear),
        ]

        await viewModel.loadData()

        XCTAssertFalse(viewModel.isLoading, "isLoading должен стать false после завершения")
        XCTAssertEqual(viewModel.profile?.id, "test-id-123", "Профиль должен быть установлен")
        XCTAssertEqual(viewModel.stickers.count, 2, "Должно быть 2 стикера")

        let sticker1 = viewModel.stickers.first { $0.id == "ach-1" }
        let sticker2 = viewModel.stickers.first { $0.id == "ach-2" }

        XCTAssertTrue(sticker1?.isUnlocked ?? false, "ach-1 должен быть разблокирован")
        XCTAssertFalse(sticker2?.isUnlocked ?? true, "ach-2 должен быть заблокирован")
    }

    func testLoadData_Success_RepositoriesCalledOnce() async {
        await viewModel.loadData()

        XCTAssertEqual(mockUsersRepo.getMyProfileCallCount, 1)
        XCTAssertEqual(mockAchievementsRepo.getAchievementsCallCount, 1)
        XCTAssertEqual(mockUsersRepo.getUserAchievementsCallCount, 1)
    }

    // MARK: - Защита от конкурентных вызовов

    func testLoadData_ConcurrentCalls_GuardPreventsMultipleRequests() async {
        mockUsersRepo.delayTime = 0.1

        // Имитируем одновременный вызов
        async let call1: Void = viewModel.loadData()
        async let call2: Void = viewModel.loadData()

        _ = await (call1, call2)

        XCTAssertEqual(mockUsersRepo.getMyProfileCallCount, 1, "Защита от повторного вызова не сработала")
        XCTAssertEqual(mockAchievementsRepo.getAchievementsCallCount, 1)
    }
}
