import Foundation

@testable import govuk_ios

extension UserState {
    static var arrange: UserState {
        .arrange()
    }
    
    static func arrange(userId: String = "user_id",
                        userNotificationsPreferences:
                        UserNotificationsPreferences = UserNotificationsPreferences(consentStatus: .unknown, notificationId: "notification_id")) -> UserState {
        .init(userId: userId, notifications: userNotificationsPreferences)
    }
    
    static var arrangeAccepted: UserState {
        .arrange(userNotificationsPreferences: UserNotificationsPreferences(consentStatus: .accepted, notificationId: "notification_id"))
    }
}

