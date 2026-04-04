import Foundation

struct GetZoneByIDEndpoint: Endpoint {
    private let zoneID: String

    init(_ zoneID: String) {
        self.zoneID = zoneID
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Zones.details(zoneID) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
