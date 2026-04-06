import Foundation

enum ScheduleError: Equatable {
    case noConnection
    case unauthorized
    case server(code: Int)
    case decoding
    case unknown

    var userFacingMessage: String {
        switch self {
        case .noConnection:
            "Нет подключения к сети. Проверьте интернет и попробуйте снова."
        case .unauthorized:
            "Требуется вход в аккаунт."
        case .server:
            "Сервер временно недоступен. Попробуйте позже."
        case .decoding:
            "Не удалось разобрать ответ сервера. Обновите приложение."
        case .unknown:
            "Что-то пошло не так. Попробуйте позже."
        }
    }

    init(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized:
                self = .unauthorized
            case .decodingFailed:
                self = .decoding
            case let .serverError(code, _):
                self = .server(code: code)
            case let .transportError(underlying):
                self = Self.transportCase(for: underlying)
            case .noResponse, .invalidURL, .encodingFailed:
                self = .unknown
            }
            return
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .timedOut:
                self = .noConnection
            default:
                self = .unknown
            }
            return
        }
        self = .unknown
    }

    private static func transportCase(for error: Error) -> ScheduleError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .timedOut:
                return .noConnection
            default:
                break
            }
        }
        return .unknown
    }
}
