import Foundation

struct UserPreferencesResponse: Codable {
    let preferences: UserPreferences
}

struct UserPreferences: Codable {
    var notificationsConsented: Bool?
    var analyticsConsented: Bool?
}
