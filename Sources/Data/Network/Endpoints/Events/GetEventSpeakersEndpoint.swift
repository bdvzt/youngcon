import Foundation

struct GetEventSpeakersEndpoint: Endpoint {
    private let eventID: String

    init(_ eventID: String) {
        self.eventID = eventID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Events.speakers(eventID)
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
