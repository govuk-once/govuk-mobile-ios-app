import Foundation

struct NotificationsPreferenceResponse: Codable {
    let preferences: NotificationsPreference
}

struct NotificationsPreference: Codable {
    let notificationsConsented: Bool
    let updatedAt: Date
}

struct AnalyticsPreferenceResponse: Codable {
    let preferences: AnalyticsPreference
}

struct AnalyticsPreference: Codable {
    let analyticsConsented: Bool
    let updatedAt: Date
}
