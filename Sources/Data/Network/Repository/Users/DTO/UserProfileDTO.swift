import Foundation

struct UserProfileDTO: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let qrCode: String
    let major: MajorDTO
    let role: UserRoleDTO
}

extension UserProfileDTO {
    func toEntity() -> UserProfile? {
        UserProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            qrCode: qrCode,
            major: major.toEntity(),
            role: role.toEntity()
        )
    }
}
