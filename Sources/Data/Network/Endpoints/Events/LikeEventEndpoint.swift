import Foundation

struct LikeEventEndpoint: Endpoint {
    private let eventID: String

    init(
        _ eventID: String
    ) {
        self.eventID = eventID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Events.like(eventID)
    }

    var method: HTTPMethod {
        .post
    }

    var task: HTTPTask {
        .request
    }

    var authorization: AuthorizationRequirement {
        .accessToken
    }
}
