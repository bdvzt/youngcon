import Foundation

struct SpeakerDTO: Codable {
    let id: String
    let fullName: String
    let job: String
    let bio: String
    let avatarURL: String?
}

extension SpeakerDTO {
    func toEntity() -> Speaker? {
        Speaker(
            id: id,
            fullName: fullName,
            job: job,
            bio: bio,
            avatarImageURL: avatarURL.flatMap { URL(string: $0) }
        )
    }
}
