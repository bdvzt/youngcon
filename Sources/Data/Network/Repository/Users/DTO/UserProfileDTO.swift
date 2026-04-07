import Foundation

struct UserProfileDTO: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let qrCode: String
    let major: Major
    let role: UserRole

    private enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case first_name
        case lastName
        case last_name
        case email
        case qrCode
        case qr_code
        case major
        case role
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
            ?? container.decodeIfPresent(String.self, forKey: .first_name)
            ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
            ?? container.decodeIfPresent(String.self, forKey: .last_name)
            ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
            ?? container.decodeIfPresent(String.self, forKey: .qr_code)
            ?? ""
        let majorRaw = try (container.decodeIfPresent(String.self, forKey: .major) ?? "").lowercased()
        switch majorRaw {
        case "devops":
            major = .devOps
        case "mobile":
            major = .mobile
        case "ml":
            major = .ml
        default:
            major = .frontend
        }
        let roleRaw = try container.decodeIfPresent(String.self, forKey: .role) ?? ""
        role = UserRole(rawValue: roleRaw) ?? .client
    }
}

extension UserProfileDTO {
    func toEntity() -> UserProfile? {
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
