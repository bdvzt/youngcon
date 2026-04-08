import Foundation
import SwiftUI

@MainActor
final class OrganizerViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    @Published var loadingError: String? = nil

    private let achievementsRepository: AchievementsRepositoryProtocol

    init(achievementsRepository: AchievementsRepositoryProtocol) {
        self.achievementsRepository = achievementsRepository
    }

    func loadAchievements() {
        guard !isLoading else { return }
        isLoading = true
        loadingError = nil

        Task {
            do {
                let items = try await achievementsRepository.getAchievements()
                self.achievements = items.sorted { $0.name < $1.name }
            } catch {
                self.loadingError = "Не удалось загрузить список ачивок"
                print("Error loading achievements: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}
