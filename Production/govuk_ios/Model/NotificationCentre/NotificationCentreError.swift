import Foundation

enum NotificationCentreError: LocalizedError {
    case notFound
    case apiUnavailable
    case decodingError
    case authenticationError
}
