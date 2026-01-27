import Foundation

enum UserStateError: LocalizedError {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case authenticationError
}

extension UserStateError {
    func asAppUnavailableError() -> AppUnavailableError {
        switch self {
        case .networkUnavailable:
                .networkUnavailable
        default:
                .userState
        }
    }
}
