import Foundation

struct GetSpeakerEventsEndpoint: Endpoint {
    private let speakerID: String

    init(
        _ speakerID: String
    ) {
        self.speakerID = speakerID
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Events.bySpeaker(speakerID)
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
