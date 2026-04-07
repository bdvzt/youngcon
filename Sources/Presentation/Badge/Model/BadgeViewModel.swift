import Foundation

@MainActor
class BadgeViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var stickers: [Sticker] = []
    @Published var isLoading = false

    private let usersRepository: UsersRepositoryProtocol
    private let achievementsRepository: AchievementsRepositoryProtocol

    init(usersRepository: UsersRepositoryProtocol, achievementsRepository: AchievementsRepositoryProtocol) {
        self.usersRepository = usersRepository
        self.achievementsRepository = achievementsRepository
    }

    func loadData() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

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
                let unlockedAchievements = try await usersRepository.getUserAchievements(userID: currentProfile.id)
                unlockedIDs = Set(unlockedAchievements.map(\.id))
            } catch {
                throw BadgeError.userProgressLoadingFailed(error)
            }

            stickers = allAchievements.map { achievement in
                let isUnlocked = unlockedIDs.contains(achievement.id)
                return Sticker(from: achievement, isUnlocked: isUnlocked)
            }
        } catch let error as BadgeError {
            print(error.description)
        } catch {
            print("[Badge] Unexpected error: \(error.localizedDescription)")
        }
    }
}
