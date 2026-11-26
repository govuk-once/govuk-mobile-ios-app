import Foundation

import OneSignalFramework

protocol OneSignalServiceClient: AnyObject {
    static func setConsentRequired(_ required: Bool)
    static func initialize(appId: String,
                           launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    static func setConsentGiven(_ given: Bool)
    static func login(_ externalId: String)
    static func logout()

    static var Notifications: any OSNotifications.Type { get }
    /// What the SDK has saved for this device. Only read when the user has consented.
    static var deviceState: OneSignalDeviceState { get }
}

struct OneSignalDeviceState {
    let externalId: String?
    let onesignalId: String?
    let pushSubscriptionId: String?
    let pushOptedIn: Bool
}

extension OneSignal: OneSignalServiceClient {
    static func initialize(appId: String,
                           launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        initialize(appId, withLaunchOptions: launchOptions)
    }

    // Wrapped in our own type rather than exposing OneSignal.User, which is a large protocol
    // that would be impractical to mock.
    static var deviceState: OneSignalDeviceState {
        OneSignalDeviceState(
            externalId: OneSignal.User.externalId,
            onesignalId: OneSignal.User.onesignalId,
            pushSubscriptionId: OneSignal.User.pushSubscription.id,
            pushOptedIn: OneSignal.User.pushSubscription.optedIn
        )
    }
}
