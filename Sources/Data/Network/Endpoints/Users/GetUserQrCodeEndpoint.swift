import Foundation

struct GetUserQrCodeEndpoint: Endpoint {
    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Users.myQR
    }

    var method: HTTPMethod {
        .get
    }

    var task: HTTPTask {
        .request
    }

    var authorization: AuthorizationRequirement {
        .accessToken
    }
}
