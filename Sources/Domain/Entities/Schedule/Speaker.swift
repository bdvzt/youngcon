import Foundation

struct Speaker: Identifiable, Decodable {
    let id: String
    let fullName: String
    let job: String
    let bio: String
    let avatarURL: String?

    var avatarImageURL: URL? {
        guard let avatarURL else { return nil }
        return URL(string: avatarURL)
    }
}
