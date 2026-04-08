import Foundation

struct ResolveQREndpoint: Endpoint {
    let qrCode: String

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Users.resolveQR
    }

    var method: HTTPMethod {
        .post
    }

    var task: HTTPTask {
        struct Body: Encodable {
            let qrCode: String
        }
        return .requestBody(Body(qrCode: qrCode))
    }

    var authorization: AuthorizationRequirement {
        .accessToken
    }
}
