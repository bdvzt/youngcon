import Foundation

struct GetEventsEndpoint: Endpoint {
    private let festivalID: String

    init(
        _ festivalID: String
    ) {
        self.festivalID = festivalID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Events.byFestival(festivalID)
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
