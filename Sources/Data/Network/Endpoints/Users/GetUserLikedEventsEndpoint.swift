import Foundation

struct GetUserLikedEventsEndpoint: Endpoint {
    private let id: String

    init(id: String) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.likedEvents(id) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
