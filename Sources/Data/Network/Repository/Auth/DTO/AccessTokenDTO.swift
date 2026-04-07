struct AccessTokenDTO: Decodable {
    let token: String

    private enum CodingKeys: String, CodingKey {
        case token
        case accessToken
        case access_token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decodeIfPresent(String.self, forKey: .token)
            ?? container.decodeIfPresent(String.self, forKey: .accessToken)
            ?? container.decodeIfPresent(String.self, forKey: .access_token)
            ?? ""
    }
}
