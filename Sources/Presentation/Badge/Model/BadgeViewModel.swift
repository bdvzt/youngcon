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
        isLoading = true
        defer { isLoading = false }
        do {
            let profile = try await usersRepository.getMyProfile()
            self.profile = profile
            let allAchievements = try await achievementsRepository.getAchievements()
            let unlockedAchievements = try await usersRepository.getUserAchievements(userID: profile.id)
            let unlockedIDs = Set(unlockedAchievements.map(\.id))
            stickers = allAchievements.map { achievement in
                let isUnlocked = unlockedIDs.contains(achievement.id)
                return Sticker(from: achievement, isUnlocked: isUnlocked)
            }
        } catch {
            print("Error loading badge data: \(error)")
        }
    }
}
