import Foundation

struct LoginEndpoint: Endpoint {
    private let body: LoginRequestDTO

    init(
        body: LoginRequestDTO
    ) {
        self.body = body
    }

    var baseURL: URL {
        APIConstants.baseURL
    }

    var path: String {
        APIConstants.Auth.login
    }

    var method: HTTPMethod {
        .post
    }

    var task: HTTPTask {
        .requestBody(body)
    }

    var authorization: AuthorizationRequirement {
        .none
    }
}
