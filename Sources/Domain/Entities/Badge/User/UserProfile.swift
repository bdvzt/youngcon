struct UserProfile: Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let qrCode: String
    let major: Major
    let role: UserRole
}
