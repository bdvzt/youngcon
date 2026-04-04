import Foundation

struct GetAchievmentsEndpoint: Endpoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Achievements.list }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
