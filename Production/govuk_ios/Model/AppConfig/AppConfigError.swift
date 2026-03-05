import Foundation

enum AppConfigError: Error {
    case remoteJson
    case invalidSignature
    case networkUnavailable
}

extension AppConfigError {
    var asAppUnavailableError: AppUnavailableError {
        if self == .networkUnavailable {
            .networkUnavailable
        } else {
            .appConfig
        }
    }
}
