import Combine
import SwiftUI

@MainActor
final class ScannerViewModel: ObservableObject {
    enum ScanState {
        case idle
        case loading
        case success(AssignResult, ResolvedUser)
        case error(String)
    }

    @Published var state: ScanState = .idle

    let achievement: Achievement
    private let organizerRepository: OrganizerRepositoryProtocol

    init(achievement: Achievement, organizerRepository: OrganizerRepositoryProtocol) {
        self.achievement = achievement
        self.organizerRepository = organizerRepository
    }

    func handle(qrCode: String) {
        guard case .idle = state else { return }
        state = .loading
        Task {
            do {
                let user = try await organizerRepository.resolveQR(qrCode)
                let result = try await organizerRepository.assignAchievement(qrCode: qrCode, achievementId: achievement.id)
                state = .success(result, user)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func reset() {
        state = .idle
    }
}
