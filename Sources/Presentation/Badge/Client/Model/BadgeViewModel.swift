import Foundation
import OSLog
import SwiftUI

@MainActor
final class BadgeViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var stickers: [Sticker] = []
    @Published var isLoading = false
    @Published var newlyUnlockedSticker: Sticker?

    private let usersRepository: UsersRepositoryProtocol
    private let achievementsRepository: AchievementsRepositoryProtocol
    private let logger = Logger(subsystem: "com.bdvzt.YoungCon", category: "Badge")
    private var pollingTask: Task<Void, Never>?
    private var knownUnlockedIDs: Set<String> = []

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

    func startPolling() {
        stopPolling()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                await self?.fetchAll(isFirstLoad: false)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func fetchAll(isFirstLoad: Bool) async {
        do {
            let currentProfile: UserProfile
            do {
                currentProfile = try await usersRepository.getMyProfile()
                profile = currentProfile
            } catch {
                throw BadgeError.profileLoadingFailed(error)
            }

            let allAchievements: [Achievement]
            do {
                allAchievements = try await achievementsRepository.getAchievements()
            } catch {
                throw BadgeError.achievementsLoadingFailed(error)
            }

            let unlockedIDs: Set<String>
            do {
                let unlockedAchievements = try await usersRepository.getUserAchievements(
                    userID: currentProfile.id
                )
                unlockedIDs = Set(unlockedAchievements.map(\.id))
            } catch {
                throw BadgeError.userProgressLoadingFailed(error)
            }

            if !isFirstLoad, !knownUnlockedIDs.isEmpty {
                let freshlyUnlocked = unlockedIDs.subtracting(knownUnlockedIDs)
                if let firstNewID = freshlyUnlocked.first,
                   let achievement = allAchievements.first(where: { $0.id == firstNewID })
                {
                    let sticker = Sticker(from: achievement, isUnlocked: true)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        newlyUnlockedSticker = sticker
                    }
                }
            }

            knownUnlockedIDs = unlockedIDs

            stickers = allAchievements.map { achievement in
                let isUnlocked = unlockedIDs.contains(achievement.id)
                return Sticker(from: achievement, isUnlocked: isUnlocked)
            }
        } catch let error as BadgeError {
            logger.error("\(error.description, privacy: .public)")
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription, privacy: .public)")
        }
    }
}
