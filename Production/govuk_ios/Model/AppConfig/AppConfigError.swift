import Foundation

enum AppConfigError: Error {
    case remoteJson
    case invalidSignature
    case networkUnavailable
}

extension AppConfigError {
    func asAppUnavailableError() -> AppUnavailableError {
        if self == .networkUnavailable {
            .networkUnavailable
        } else {
            .appConfig
        }
    }
}
