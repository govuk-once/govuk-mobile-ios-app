import Foundation
import GovKit

enum NotificationPermissionResultType: String {
    /// The user answered the system permission prompt
    case system = "System"
    /// The permission state when the user returned from the Settings app
    case settings = "Settings"
}

extension AppEvent {
    static func toggle(text: String,
                       section: String,
                       isOn: Bool) -> AppEvent {
        function(
            text: text,
            type: "Toggle",
            section: section,
            action: isOn ? "On" : "Off"
        )
    }

    static func notificationPermissionResult(type: NotificationPermissionResultType,
                                             section: String,
                                             granted: Bool) -> AppEvent {
        function(
            text: "Notification permission",
            type: type.rawValue,
            section: section,
            action: granted ? "Granted" : "Denied"
        )
    }

    static func toggleAction(text: String,
                             section: String,
                             action: String) -> AppEvent {
        function(
            text: text,
            type: "Toggle",
            section: section,
            action: action
        )
    }
}
