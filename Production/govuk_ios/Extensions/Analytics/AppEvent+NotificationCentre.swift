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
}
