import Foundation
import Testing

@testable import GovKit
@testable import govuk_ios

struct VehicleCheckAnalyticsTests {

    @Test
    func trackSubmitButtonTapEvent_tracksExpectedAppEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()

        VehicleCheckAnalytics.trackSubmitButtonTapEvent(analyticsService: mockAnalyticsService)

        #expect(mockAnalyticsService._trackedEvents.count == 1)

        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Widget")
        #expect(event.params?["text"] as? String == "Submit")
        #expect(event.params?["action"] as? String == "Search number plate")
        #expect(event.params?["external"] as? Bool == false)
        #expect(event.params?["section"] as? String == "Driving")
    }

    @Test
    func trackCancelButtonTapEvent_tracksExpectedAppEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()

        VehicleCheckAnalytics.trackCancelButtonTapEvent(analyticsService: mockAnalyticsService)

        #expect(mockAnalyticsService._trackedEvents.count == 1)

        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Widget")
        #expect(event.params?["text"] as? String == "Cancel")
        #expect(event.params?["action"] as? String == "Cancel search number plate")
        #expect(event.params?["external"] as? Bool == false)
        #expect(event.params?["section"] as? String == "Driving")
    }
}
