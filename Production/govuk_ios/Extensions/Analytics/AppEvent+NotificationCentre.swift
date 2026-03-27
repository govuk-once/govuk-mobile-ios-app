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
        .init(name: "NotificationCentreDelete", params: nil)
    }

    static func notificationCentreConfirmDelete() -> AppEvent {
        .init(name: "NotificationCentreConfirmDelete", params: nil)
    }

    static func notificationCentreCancelDelete() -> AppEvent {
        .init(name: "NotificationCentreCancelDelete", params: nil)
    }
}
