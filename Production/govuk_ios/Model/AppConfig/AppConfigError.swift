import Foundation

enum AppConfigError: Error {
    case configAPI
    case parsingError
    case invalidSignature
    case networkUnavailable
    case termsAndConditionsAPI
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
