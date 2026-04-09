import Foundation
import OSLog
import SwiftUI

@MainActor
final class BadgeViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var stickers: [Sticker] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var shouldCloseQR = false
    @Published var newlyUnlockedSticker: Sticker?

    private let usersRepository: UsersRepositoryProtocol
    private let achievementsRepository: AchievementsRepositoryProtocol
    private let logger = Logger(subsystem: "com.bdvzt.YoungCon", category: "Badge")
    private var pollingTask: Task<Void, Never>?
    private var knownUnlockedIDs: Set<String> = []
    private var currentPollingInterval: TimeInterval?

    init(
        usersRepository: UsersRepositoryProtocol,
        achievementsRepository: AchievementsRepositoryProtocol
    ) {
        self.usersRepository = usersRepository
        self.achievementsRepository = achievementsRepository
    }

    func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        await fetchAll(isFirstLoad: true, policy: .cacheFirst)
    }

    func refreshFromNetworkIfNeeded() async {
        guard !isLoading, !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        await fetchAll(isFirstLoad: false, policy: .networkFirst)
    }

    func startPolling(every interval: TimeInterval = 1) {
        guard currentPollingInterval != interval else { return }

        stopPolling()
        currentPollingInterval = interval

        pollingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(interval))
                } catch {
                    break
                }

                guard !Task.isCancelled else { break }
                await refreshFromNetworkIfNeeded()
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        currentPollingInterval = nil
    }

    private func fetchAll(isFirstLoad: Bool, policy: CachePolicy) async {
        do {
            let payload = try await loadBadgePayload(policy: policy)
            let newUnlockedIDs = makeUnlockedIDs(from: payload.unlockedAchievements)

            if isFirstLoad {
                apply(
                    profile: payload.profile,
                    achievements: payload.allAchievements,
                    unlockedIDs: newUnlockedIDs
                )
                return
            }

            let profileChanged = profile != payload.profile
            let achievementCatalogChanged = stickers.map(\.id) != payload.allAchievements.map(\.id)
            let unlockedChanged = knownUnlockedIDs != newUnlockedIDs

            if !profileChanged, !achievementCatalogChanged, !unlockedChanged {
                return
            }

            let freshlyUnlocked = newUnlockedIDs.subtracting(knownUnlockedIDs)
            let hasOnlyNewUnlocks =
                !freshlyUnlocked.isEmpty &&
                !profileChanged &&
                !achievementCatalogChanged &&
                knownUnlockedIDs.isSubset(of: newUnlockedIDs)

            if hasOnlyNewUnlocks {
                knownUnlockedIDs = newUnlockedIDs
                showNewlyUnlockedStickerIfNeeded(
                    freshlyUnlockedIDs: freshlyUnlocked,
                    allAchievements: payload.allAchievements
                )
                return
            }

            apply(
                profile: payload.profile,
                achievements: payload.allAchievements,
                unlockedIDs: newUnlockedIDs
            )
        } catch let error as BadgeError {
            logger.error("\(error.description, privacy: .public)")
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription, privacy: .public)")
        }
    }
}

private extension BadgeViewModel {
    struct BadgePayload {
        let profile: UserProfile
        let allAchievements: [Achievement]
        let unlockedAchievements: [Achievement]
    }

    func loadBadgePayload(policy: CachePolicy) async throws -> BadgePayload {
        async let currentProfileTask = usersRepository.getMyProfile(policy: policy)
        async let allAchievementsTask = achievementsRepository.getAchievements(policy: policy)

        let currentProfile = try await currentProfileTask
        let allAchievements = try await allAchievementsTask
        let unlockedAchievements = try await usersRepository.getUserAchievements(
            userID: currentProfile.id,
            policy: policy
        )

        return BadgePayload(
            profile: currentProfile,
            allAchievements: allAchievements,
            unlockedAchievements: unlockedAchievements
        )
    }

    func makeUnlockedIDs(from achievements: [Achievement]) -> Set<String> {
        Set(achievements.map(\.id))
    }

    func showNewlyUnlockedStickerIfNeeded(
        freshlyUnlockedIDs: Set<String>,
        allAchievements: [Achievement]
    ) {
        guard let firstNewID = freshlyUnlockedIDs.first else { return }

        let updatedStickers = allAchievements.map { achievement in
            let isUnlocked = knownUnlockedIDs.contains(achievement.id)
            return Sticker(from: achievement, isUnlocked: isUnlocked)
        }

        guard let sticker = updatedStickers.first(where: { $0.id == firstNewID }) else {
            return
        }

        shouldCloseQR = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))

            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                newlyUnlockedSticker = sticker
            }
        }
    }

    func apply(profile: UserProfile, achievements: [Achievement], unlockedIDs: Set<String>) {
        knownUnlockedIDs = unlockedIDs
        self.profile = profile
        stickers = achievements.map { achievement in
            let isUnlocked = unlockedIDs.contains(achievement.id)
            return Sticker(from: achievement, isUnlocked: isUnlocked)
        }
    }
}
