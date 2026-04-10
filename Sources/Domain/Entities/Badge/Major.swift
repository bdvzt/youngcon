enum Major: Equatable {
    case frontend
    case ios
    case flutter
    case android
    case backend
    case ml
    case devOps
}

extension Major {
    var title: String {
        switch self {
        case .frontend:
            "Frontend"
        case .ios:
            "iOS"
        case .flutter:
            "Flutter"
        case .android:
            "Android"
        case .backend:
            "Backend"
        case .ml:
            "ML"
        case .devOps:
            "DevOps"
        }
    }
}
