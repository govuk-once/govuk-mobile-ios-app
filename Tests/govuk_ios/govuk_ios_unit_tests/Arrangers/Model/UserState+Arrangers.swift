import Foundation

@testable import govuk_ios

extension UserState {
    static var arrange: UserState {
        .arrange()
    }
    
    static func arrange(userId: String = "user_id",
                        userNotificationsPreferences:
                        UserNotificationsPreferences =
                        UserNotificationsPreferences(consentStatus: .unknown, pushId: "push_id")
    ) -> UserState {
        .init(userId: userId, notifications: userNotificationsPreferences)
    }
    
    static var arrangeAccepted: UserState {
        .arrange(userNotificationsPreferences: UserNotificationsPreferences(consentStatus: .accepted, pushId: "push_id"))
    }
    
    static func arrange(pushId: String = "push_id") -> UserState {
        .init(userId: "user_id", notifications: UserNotificationsPreferences(consentStatus: .unknown, pushId: pushId))
    }
    
}

