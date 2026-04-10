import Foundation

struct ResolvedUserDTO: Decodable {
    let userId: String
    let firstName: String
    let lastName: String
    let qrCode: String
}
