import Foundation

struct NotificationsPreferenceResponse: Codable {
    let notifications: NotificationsPreference
}

struct NotificationsPreference: Codable {
    let consentStatus: ConsentStatus
    let updatedAt: Date
}
