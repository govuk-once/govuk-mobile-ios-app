import Foundation
import GovKit

extension AppEvent {
    static func drivingAccountCardNavigation(
        text: String,
        url: String
    ) -> AppEvent {
        navigation(
            text: text,
            type: "Account card",
            external: true,
            additionalParams: [
                "url": url,
                "section": "Driving"
            ]
        )
    }
}
