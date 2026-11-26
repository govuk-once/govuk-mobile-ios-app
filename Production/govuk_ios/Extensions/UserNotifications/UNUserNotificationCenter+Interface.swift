import Foundation
import UserNotifications

protocol UserNotificationCenterInterface {
    var authorizationStatus: UNAuthorizationStatus { get async }
    // Already implemented by UNUserNotificationCenter. Listed here so NotificationService can
    // ask iOS for permission itself, before giving OneSignal consent.
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
}

extension UNUserNotificationCenter: UserNotificationCenterInterface {
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            await notificationSettings().authorizationStatus
        }
    }
}
