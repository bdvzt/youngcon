struct LikeEventResponse: Decodable {
    let eventID: String
    let userID: String
    let isLiked: Bool
}
