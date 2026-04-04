import Foundation

struct GetLastFestivalEndpoint: Endpoint {
    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Festivals.last
    }

    var method: HTTPMethod {
        .get
    }

    var task: HTTPTask {
        .request
    }

    var authorization: AuthorizationRequirement {
        .none
    }
}
