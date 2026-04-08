import Foundation

final class OrganizerRepository: OrganizerRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let tokenStorage: TokenStorageProtocol

    init(networkService: NetworkServiceProtocol, tokenStorage: TokenStorageProtocol) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }

    func resolveQR(_ qrCode: String) async throws -> ResolvedUser {
        let endpoint = ResolveQREndpoint(qrCode: qrCode)
        let dto = try await networkService.requestDecodable(endpoint, as: ResolvedUserDTO.self)

        return ResolvedUser(
            userId: dto.userId,
            firstName: dto.firstName,
            lastName: dto.lastName,
            qrCode: dto.qrCode
        )
    }

    func assignAchievement(qrCode: String, achievementId: String) async throws -> AssignResult {
        let endpoint = AssignAchievementEndpoint(qrCode: qrCode, achievementId: achievementId)
        let dto = try await networkService.requestDecodable(endpoint, as: AssignResultDTO.self)

        return AssignResult(
            userId: dto.userId,
            achievementId: dto.achievmentId,
            assignedNow: dto.assignedNow
        )
    }
}
