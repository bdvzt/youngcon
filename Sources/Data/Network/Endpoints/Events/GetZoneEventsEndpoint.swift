import Foundation

struct GetZoneEventsEndpoint: Endpoint {
    private let zoneID: String

    init(
        _ zoneID: String
    ) {
        self.zoneID = zoneID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Events.byZone(zoneID)
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
