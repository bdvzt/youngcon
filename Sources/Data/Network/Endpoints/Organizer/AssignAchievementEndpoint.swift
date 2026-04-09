import Foundation

struct AssignAchievementEndpoint: Endpoint {
    let qrCode: String
    let achievementId: String

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Users.assignAchievementByQR
    }

    var method: HTTPMethod {
        .post
    }

    var task: HTTPTask {
        struct Body: Encodable {
            let qrCode: String
            let achievmentId: String
        }
        return .requestBody(Body(qrCode: qrCode, achievmentId: achievementId))
    }

    var authorization: AuthorizationRequirement {
        .accessToken
    }
}
