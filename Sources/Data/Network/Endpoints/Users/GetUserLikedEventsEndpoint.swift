import Foundation

struct GetUserLikedEventsEndpoint: Endpoint {
    init(
        _ userID: String
    ) {
        _ = userID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Users.myLikedEvents
    }

    var method: HTTPMethod {
        .get
    }

    var task: HTTPTask {
        .request
    }

    var authorization: AuthorizationRequirement {
        .accessToken
    }
}
