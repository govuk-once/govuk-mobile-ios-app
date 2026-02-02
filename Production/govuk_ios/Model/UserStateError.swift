import Foundation

enum UserStateError: LocalizedError {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case authenticationError
}

extension UserStateError {
    func asAppUnavailableError() -> AppUnavailableError {
        if self == .networkUnavailable {
            .networkUnavailable
        } else {
            .userState
        }
    }
}
