import Foundation

struct UserState: Codable {
    let userId: String
    let notifications: UserNotificationsPreferences
}

struct UserNotificationsPreferences: Codable {
    let consentStatus: ConsentStatus
    let pushId: String
}

struct ConsentPreference: Codable {
    let consentStatus: ConsentStatus
}

enum ConsentStatus: String, Codable {
    case accepted
    case denied
    case unknown
}
