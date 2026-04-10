enum UserRoleDTO: String, Codable, Equatable {
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
