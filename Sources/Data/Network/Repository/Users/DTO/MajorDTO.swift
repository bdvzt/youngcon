enum MajorDTO: String, Decodable {
    case frontend = "Frontend"
    case ios = "IOS"
    case flutter = "Flutter"
    case android = "Android"
    case backend = "Backend"
    case ml = "ML"
    case devOps = "DevOps"
}

extension MajorDTO {
    func toEntity() -> Major {
        switch self {
        case .frontend:
            .frontend
        case .ios:
            .ios
        case .flutter:
            .flutter
        case .android:
            .android
        case .backend:
            .backend
        case .ml:
            .ml
        case .devOps:
            .devOps
        }
    }
}
