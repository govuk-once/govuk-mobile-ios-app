import Foundation

/// Reported on app start when what the OneSignal SDK saved from previous sessions doesn't match
/// a user who has consented, i.e. the device isn't properly linked to their external ID. Pushes
/// sent to that user then fail ("can't find the ID" or "not subscribed").
///
/// The app logs in again straight after the check, which usually repairs the state. That
/// self-healing is what has made these failures invisible, so this records them first.
///
/// Holds flags only, so a report never contains an ID.
struct OneSignalStateError: Error, Equatable {
    let externalIdSet: Bool
    let externalIdMatches: Bool
    let onesignalIdSet: Bool
    let pushSubscriptionIdSet: Bool
    /// Reported for context only. It depends on the OS permission, which the user is free to
    /// turn off, so on its own it doesn't mean anything is wrong.
    let pushOptedIn: Bool

    /// A consented user should be logged in as themselves, exist on OneSignal's server and have
    /// a push subscription. None of these depend on the OS permission: the SDK links the
    /// external ID and creates the subscription whether or not notifications are allowed.
    var isConsistent: Bool {
        externalIdMatches && onesignalIdSet && pushSubscriptionIdSet
    }
}

// Crashlytics groups recorded errors by domain and code, so every report lands in one issue,
// and it attaches userInfo to each event, which is how the flags reach the report.
extension OneSignalStateError: CustomNSError {
    var errorUserInfo: [String: Any] {
        [
            "externalIdSet": externalIdSet,
            "externalIdMatches": externalIdMatches,
            "onesignalIdSet": onesignalIdSet,
            "pushSubscriptionIdSet": pushSubscriptionIdSet,
            "pushOptedIn": pushOptedIn
        ]
    }
}
