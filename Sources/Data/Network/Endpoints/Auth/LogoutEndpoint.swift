import Foundation

struct LogoutEndPoint: Endpoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Auth.logout }
    var method: HTTPMethod { .post }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .accessToken }
}
