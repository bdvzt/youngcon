import Foundation

struct Speaker: Identifiable, Codable {
    let id: UUID
    let name: String
    let role: String
    let bio: String
    let photoURL: URL?
}
