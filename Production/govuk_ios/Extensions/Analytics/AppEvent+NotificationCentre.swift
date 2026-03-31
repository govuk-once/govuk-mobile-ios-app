//
import Foundation
import GovKit

extension AppEvent {
    static func notificationCentreUrlLaunched(url: URL) -> AppEvent {
        .init(name: "NotificationCentreUrlLaunched",
              params: [
                "url": url.absoluteString
              ]
        )
    }

    static func notificationCentreNotFound() -> AppEvent {
        .init(name: "NotificationCentreNotFound", params: nil)
    }

    static func notificationCentreMarkUnread() -> AppEvent {
        .init(name: "NotificationCentreMarkUnread", params: nil)
    }

    static func notificationCentreDelete() -> AppEvent {
        .init(name: "NotificationCentreDelete", params: [
            "action": "tap"
        ])
    }

    static func notificationCentreConfirmDelete() -> AppEvent {
        .init(name: "NotificationCentreDelete", params: [
            "action": "confirm"
        ])
    }

    static func notificationCentreCancelDelete() -> AppEvent {
        .init(name: "NotificationCentreDelete", params: [
            "action": "cancel"
        ])
    }
}
