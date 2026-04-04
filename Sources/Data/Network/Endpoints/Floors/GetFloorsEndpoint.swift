import Foundation

struct GetFloorsEndpoint: Endpoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Floors.list }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
