import Foundation

@testable import govuk_ios

extension UserState {
    static var arrange: UserState {
        .arrange()
    }

    static func arrange(notificationId: String = "test_id",
                        notificationsConsentStatus: ConsentStatus = .unknown) -> UserState {
        .init(
            notificationId: notificationId,
            preferences: UserPreferences(
                notifications: ConsentPreference(
                    consentStatus: notificationsConsentStatus
                )
            )
        )
    }
}

