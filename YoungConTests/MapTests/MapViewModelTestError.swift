import Foundation

enum MapViewModelTestError: LocalizedError {
    case missingStub
    case floorsLoadFailed
    case zoneLoadFailed

    var errorDescription: String? {
        switch self {
        case .missingStub:
            "Missing test stub"
        case .floorsLoadFailed:
            "Floors load failed"
        case .zoneLoadFailed:
            "Zone load failed"
        }
    }
}
