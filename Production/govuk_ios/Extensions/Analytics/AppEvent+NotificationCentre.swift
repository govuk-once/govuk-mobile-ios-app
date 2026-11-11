import Foundation
import GovKit

extension AppEvent {
    static func notificationCentreUrlLaunched(url: URL) -> AppEvent {
        .init(name: "MessagesUrlLaunched",
              params: [
                "url": url.absoluteString
              ]
        )
    }

    static func notificationCentreNotFound() -> AppEvent {
        .init(name: "MessagesNotFound", params: nil)
    }

    static func notificationCentreMarkUnread() -> AppEvent {
        .init(name: "MessagesMarkUnread", params: nil)
    }

    static func notificationCentreDelete() -> AppEvent {
        .init(name: "MessagesDelete", params: [
            "action": "tap"
        ])
    }

    static func notificationCentreConfirmDelete() -> AppEvent {
        .init(name: "MessagesDelete", params: [
            "action": "confirm"
        ])
    }

    static func notificationCentreCancelDelete() -> AppEvent {
        .init(name: "MessagesDelete", params: [
            "action": "cancel"
        ])
    }
}
