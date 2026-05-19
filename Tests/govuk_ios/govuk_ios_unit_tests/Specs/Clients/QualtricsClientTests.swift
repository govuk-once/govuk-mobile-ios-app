import Foundation
import Qualtrics
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct QualtricsClientTests {

    @Test
    @MainActor
    func trackScreen_evaluatesViewEventWithParams() {
        let mockQualtricsService = MockQualtricsService()
        let sut = QualtricsClient(
            qualtricsService: mockQualtricsService
        )

        let expectedScreen = MockBaseViewController(
            analyticsService: MockAnalyticsService()
        )
        let expectedTitle = UUID().uuidString
        expectedScreen.title = expectedTitle

        sut.track(screen: expectedScreen)

        #expect(mockQualtricsService._didCallEvaluateViewEvent)
        #expect(mockQualtricsService._stubbedScreenName == expectedScreen.trackingName)
        let params = mockQualtricsService._stubbedViewParams
        #expect(params?["screen_name"] == expectedScreen.trackingName)
        #expect(params?["screen_title"] == expectedTitle)
        #expect(params?["screen_class"] == "MockBaseViewController")
        #expect(params?["language"] == "en")
        #expect(params?["test_param"] == "test_value")
    }

    @Test
    func trackEvent_evaluatesClickEventWithParams() {
        let mockQualtricsService = MockQualtricsService()
        let sut = QualtricsClient(
            qualtricsService: mockQualtricsService
        )

        let event = AppEvent.buttonFunction(
            text: "Test button",
            section: "Test",
            action: "Click")

        sut.track(event: event)

        #expect(mockQualtricsService._didCallEvaluateClickEvent)
        let params = mockQualtricsService._stubbedClickParams
        #expect(params?["text"] == "Test button")
        #expect(params?["section"] == "Test")
        #expect(params?["action"] == "Click")
    }

    @Test
    func trackEcommmerceEvent_viewList_doesNot_evaluatesClickEventWithParams() {
        let mockQualtricsService = MockQualtricsService()
        let sut = QualtricsClient(
            qualtricsService: mockQualtricsService
        )

        let event = AppEvent.viewItemList(
            name: "list_name",
            id: "list_id",
            items: [])

        sut.track(event: event)

        #expect(!mockQualtricsService._didCallEvaluateClickEvent)
        #expect(mockQualtricsService._stubbedClickParams == nil)
    }

    @Test
    func trackEcommmerceEvent_selectItem_doesNot_evaluatesClickEventWithParams() {
        let mockQualtricsService = MockQualtricsService()
        let sut = QualtricsClient(
            qualtricsService: mockQualtricsService
        )

        let event = AppEvent.selectItem(
            listName: "list_name",
            listId: "list_id",
            results: 0,
            items: [])

        sut.track(event: event)

        #expect(!mockQualtricsService._didCallEvaluateClickEvent)
        #expect(mockQualtricsService._stubbedClickParams == nil)
    }
}
