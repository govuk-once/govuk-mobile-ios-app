import Foundation

struct UserState: Codable {
    let notificationId: String
    var preferences: UserPreferences
}
