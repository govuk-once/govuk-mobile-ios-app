import Foundation
import GovKit

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
