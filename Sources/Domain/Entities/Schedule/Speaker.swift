import Foundation

struct Speaker: Identifiable, Equatable {
    let id: String
    let fullName: String
    let job: String
    let bio: String
    let avatarImageURL: URL?
}
