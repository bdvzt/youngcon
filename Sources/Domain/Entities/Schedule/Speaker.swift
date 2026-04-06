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

    enum CodingKeys: String, CodingKey {
        case id, fullName, job, bio, avatarURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        job = try container.decodeIfPresent(String.self, forKey: .job) ?? ""
        bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL)
    }
}
