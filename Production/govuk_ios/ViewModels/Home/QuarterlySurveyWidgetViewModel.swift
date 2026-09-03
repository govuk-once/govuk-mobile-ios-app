import Foundation
import GovKit

struct QuarterlySurveyWidgetViewModel {
    private let analyticsService: AnalyticsServiceInterface

    init( analyticsService: AnalyticsServiceInterface) {
        self.analyticsService = analyticsService
    }

    func action() {
        let event = AppEvent.navigation(
            text: "Qualtrics quarterly survey",
            type: "Button",
            external: false
        )
        analyticsService.track(event: event)
    }
}
