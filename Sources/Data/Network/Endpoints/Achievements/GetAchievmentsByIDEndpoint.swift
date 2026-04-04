import Foundation

struct GetAchievmentsByIDEndpoint: Endpoint {
    private let achievementID: String

    init(_ achievementID: String) {
        self.achievementID = achievementID
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Achievements.details(achievementID) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
