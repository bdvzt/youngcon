import Foundation

struct GetZonesByFloorIDEndpoint: Endpoint {
    private let floorID: String

    init(_ floorID: String) {
        self.floorID = floorID
    }

    var baseURL: URL { APIConstants.baseURL }
    var path: String { APIConstants.Zones.byFloor(floorID) }
    var method: HTTPMethod { .get }
    var task: HTTPTask { .request }
    var authorization: AuthorizationRequirement { .none }
}
