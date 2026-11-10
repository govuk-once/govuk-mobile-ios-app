import Foundation
import GovKit

/// Holds utility methods for firing off analytic events in the Vehicle Check functionality
enum VehicleCheckAnalytics {
    static func trackSubmitButtonTapEvent(analyticsService: AnalyticsServiceInterface) {
        let event = AppEvent(
            name: "Navigation",
            params: [
                "type": "Widget",
                "text": "Submit",
                "action": "Search number plate",
                "external": false,
                "section": "Driving"
            ]
        )
        analyticsService.track(event: event)
    }

    static func trackCancelButtonTapEvent(analyticsService: AnalyticsServiceInterface) {
        let event = AppEvent(
            name: "Navigation",
            params: [
                "type": "Widget",
                "text": "Cancel",
                "action": "Cancel search number plate",
                "external": false,
                "section": "Driving"
            ]
        )
        analyticsService.track(event: event)
    }
}
