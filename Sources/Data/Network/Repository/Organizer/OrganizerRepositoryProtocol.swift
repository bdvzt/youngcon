import Foundation

protocol OrganizerRepositoryProtocol {
    func resolveQR(_ qrCode: String) async throws -> ResolvedUser
    func assignAchievement(qrCode: String, achievementId: String) async throws -> AssignResult
}
