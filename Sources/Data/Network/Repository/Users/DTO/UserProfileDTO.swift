import Foundation

struct UserProfileDTO: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let qrCode: String
    let major: Major
    let role: UserRole
}

extension UserProfileDTO {
    func toEntity() -> UserProfile {
        UserProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            qrCode: qrCode,
            major: major,
            role: role
        )
    }
}
