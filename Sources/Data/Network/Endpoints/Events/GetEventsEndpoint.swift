import Foundation

struct GetEventsEndpoint: Endpoint {
    private let id: String

    init(id: String) {
        self.id = id
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Events.byFestival(id) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
