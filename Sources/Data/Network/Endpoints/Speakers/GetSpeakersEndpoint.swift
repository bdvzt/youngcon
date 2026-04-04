import Foundation

struct GetSpeakersEndpoint: Endpoint {
    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Speakers.list }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
