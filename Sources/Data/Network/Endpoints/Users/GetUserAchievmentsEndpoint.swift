import Foundation

struct GetUserAchievmentsEndpoint: Endpoint {
    private let userID: String

    init(
        _ userID: String
    ) {
        self.userID = userID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Users.achievements(userID)
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
