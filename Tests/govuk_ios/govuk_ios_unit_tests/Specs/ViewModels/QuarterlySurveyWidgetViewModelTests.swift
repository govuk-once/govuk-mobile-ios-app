import Foundation
import Testing

@testable import govuk_ios

@Suite
struct QuarterlySurveyWidgetViewModelTests {
    @Test
    func action_tracks_navigationEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = QuarterlySurveyWidgetViewModel(
            analyticsService: mockAnalyticsService
        )
        sut.action()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Qualtrics quarterly survey")
        #expect(mockAnalyticsService._trackedEvents.first?.params?["type"] as? String == "Button")
        #expect(mockAnalyticsService._trackedEvents.first?.params?["external"] as? Bool == false)
    }
}
