import Foundation
import GovKit

extension AppEvent {
    static func linkServiceAccountNavigation(title: String) -> AppEvent {
        AppEvent.navigation(
            text: title,
            type: "trigger card",
            external: false,
            additionalParams: [
                "section": "account link"
            ]
        )
    }
}
