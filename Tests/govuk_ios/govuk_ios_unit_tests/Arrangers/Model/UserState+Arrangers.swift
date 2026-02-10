import Foundation

@testable import govuk_ios

extension UserState {
    static var arrange: UserState {
        .arrange()
    }

    static func arrange(notificationId: String = "test_id") -> UserState {
        .init(
            notificationId: notificationId,
            preferences: UserPreferences(
                notifications: ConsentPreference(
                    consentStatus: .unknown,
                    updatedAt: Date()
                ),
                analytics: ConsentPreference(
                    consentStatus: .unknown,
                    updatedAt: Date()
                )
            )
        )
    }
}

