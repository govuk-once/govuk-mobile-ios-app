import Foundation

struct NotificationsPreferenceResponse: Codable {
    let preferences: NotificationsPreference
}

struct NotificationsPreference: Codable {
    let notificationsConsented: Bool
    let updatedAt: Date
}
