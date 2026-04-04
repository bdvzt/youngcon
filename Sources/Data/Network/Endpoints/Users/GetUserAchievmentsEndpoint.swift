import Foundation

struct GetUserAchievmentsEndpoint: Endpoint {
    private let id: String

    init(id: String) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Users.achievements(id) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
