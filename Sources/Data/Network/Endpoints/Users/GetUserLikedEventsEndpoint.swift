import Foundation

struct GetUserLikedEventsEndpoint: Endpoint {
    private let userID: String

    init(_ userID: String) {
        self.userID = userID
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.likedEvents(userID) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
