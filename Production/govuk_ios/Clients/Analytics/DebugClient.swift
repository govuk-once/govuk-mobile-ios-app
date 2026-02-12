import Foundation

import FirebaseCrashlytics
import GovKit

struct DebugClient: AnalyticsClient {
    func setEnabled(enabled: Bool) {
        /* Do nothing */
    }

    func launch() { /*Do nothing */ }

    func track(screen: any TrackableScreen) {
        debugPrint("Screen: \(screen.trackingName)")
    }

    func track(event: AppEvent) {
        debugPrint("Event: \(event)")
    }

    func track(error: any Error) {
        debugPrint("Error: \(error)")
    }

    func set(userProperty: UserProperty) { /*Do nothing */ }
}
