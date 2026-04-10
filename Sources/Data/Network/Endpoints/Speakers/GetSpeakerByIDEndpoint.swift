import Foundation

struct GetSpeakerByIDEndpoint: Endpoint {
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
        APIConstants.Speakers.details(speakerID)
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
