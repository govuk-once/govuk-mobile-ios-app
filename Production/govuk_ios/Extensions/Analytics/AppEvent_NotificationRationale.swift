import Foundation
import GovKit

extension AppEvent {
    static func notificationRationaleView(origin: String) -> AppEvent {
        return .init(
            name: "notifications_rationale_view",
            params: ["origin": origin]
        )
    }

    static func notificationRationaleSettingsContinue(origin: String) -> AppEvent {
        return .init(
            name: "notifications_rationale_settings_continue",
            params: ["origin": origin]
        )
    }

    static func notificationRationaleSettingsCancel(origin: String) -> AppEvent {
        return .init(
            name: "notifications_rationale_settings_cancel",
            params: ["origin": origin]
        )
    }
}
