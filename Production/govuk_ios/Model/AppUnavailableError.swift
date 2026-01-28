import Foundation

enum AppUnavailableError: LocalizedError {
    case networkUnavailable
    case appConfig
    case userState
}
