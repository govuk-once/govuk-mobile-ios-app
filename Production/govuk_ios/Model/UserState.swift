import Foundation

struct UserState: Codable {
    let notificationId: String
    let preferences: UserPreferences
}

struct UserPreferences: Codable {
    let notifications: ConsentPreference
}

struct ConsentPreference: Codable {
    let consentStatus: ConsentStatus
}

enum ConsentStatus: String, Codable {
    case accepted
    case denied
    case unknown
}
