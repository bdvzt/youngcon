enum UserRoleDTO: String, Decodable {
    case client = "Client"
    case employee = "Employee"
}

extension UserRoleDTO {
    func toEntity() -> UserRole {
        switch self {
        case .client:
            .client
        case .employee:
            .employee
        }
    }
}
