import Foundation

enum NotificationCentreError: LocalizedError {
    case networkUnavailable
    case notFound
    case apiUnavailable
    case decodingError
    case authenticationError
}
