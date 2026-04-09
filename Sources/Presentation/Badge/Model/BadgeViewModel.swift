import Foundation
import SwiftUI

@MainActor
final class BadgeViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var stickers: [Sticker] = []
    @Published var isLoading = false
    @Published var shouldCloseQR = false
    @Published var newlyUnlockedSticker: Sticker?

    private let usersRepository: UsersRepositoryProtocol
    private let achievementsRepository: AchievementsRepositoryProtocol

    private var isRefreshing = false
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

        await fetchAll(isFirstLoad: true)
    }

    func refresh() async {
        await fetchAll(isFirstLoad: false)
    }

    func startPolling(every interval: TimeInterval) {
        guard currentPollingInterval != interval else {
            return
        }

        stopPolling()
        currentPollingInterval = interval

        pollingTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }
                await fetchAll(isFirstLoad: false)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        currentPollingInterval = nil
    }

    private func fetchAll(isFirstLoad: Bool) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let payload = try await loadBadgePayload()
            let newUnlockedIDs = makeUnlockedIDs(from: payload.unlockedAchievements)

            guard shouldApplyChanges(
                isFirstLoad: isFirstLoad,
                newProfile: payload.profile,
                newUnlockedIDs: newUnlockedIDs,
                newAchievements: payload.allAchievements
            ) else {
                return
            }

            showNewlyUnlockedStickerIfNeeded(
                isFirstLoad: isFirstLoad,
                newUnlockedIDs: newUnlockedIDs,
                allAchievements: payload.allAchievements
            )

            apply(
                profile: payload.profile,
                achievements: payload.allAchievements,
                unlockedIDs: newUnlockedIDs
            )
        } catch let error as BadgeError {
            print(error.description)
        } catch {
            print("[Badge] Unexpected error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Private helpers

private extension BadgeViewModel {
    struct BadgePayload {
        let profile: UserProfile
        let allAchievements: [Achievement]
        let unlockedAchievements: [Achievement]
    }

    func loadBadgePayload() async throws -> BadgePayload {
        async let currentProfileTask = usersRepository.getMyProfile()
        async let allAchievementsTask = achievementsRepository.getAchievements()

        let currentProfile = try await currentProfileTask
        let allAchievements = try await allAchievementsTask
        let unlockedAchievements = try await usersRepository.getUserAchievements(
            userID: currentProfile.id
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

    func shouldApplyChanges(
        isFirstLoad: Bool,
        newProfile: UserProfile,
        newUnlockedIDs: Set<String>,
        newAchievements: [Achievement]
    ) -> Bool {
        if isFirstLoad {
            return true
        }

        let profileChanged = profile != newProfile
        let unlockedChanged = knownUnlockedIDs != newUnlockedIDs
        let stickersChanged = stickers.map(\.id) != newAchievements.map(\.id)

        return profileChanged || unlockedChanged || stickersChanged
    }

    func showNewlyUnlockedStickerIfNeeded(
        isFirstLoad: Bool,
        newUnlockedIDs: Set<String>,
        allAchievements: [Achievement]
    ) {
        guard !isFirstLoad, !knownUnlockedIDs.isEmpty else { return }

        let freshlyUnlocked = newUnlockedIDs.subtracting(knownUnlockedIDs)

        guard let firstNewID = freshlyUnlocked.first else { return }

        let updatedStickers = allAchievements.map { achievement in
            let isUnlocked = newUnlockedIDs.contains(achievement.id)
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
