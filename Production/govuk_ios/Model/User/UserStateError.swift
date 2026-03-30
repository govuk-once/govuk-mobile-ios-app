import Foundation

enum UserStateError: LocalizedError {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case authenticationError
}

extension UserStateError {
    var asAppUnavailableError: AppUnavailableError {
        if self == .networkUnavailable {
            .networkUnavailable
        } else {
            .userState
        }
    }
}
