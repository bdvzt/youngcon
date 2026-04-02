import Foundation

struct UserProfile: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let major: Major
    let qr: String
}
