//


import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct TravelTopicWidgetViewModelTests {

    @Test
    func initialState_isLoadingAndSheetClosed() {
        let sut = TravelTopicWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService()
        )

        if case .loading = sut.viewState {
            // expected
        } else {
            Issue.record("Expected initial state to be .loading")
        }
        #expect(sut.isShowingList == false)
    }

    @Test
    func viewDidAppear_whenFetchSucceeds_setsLoadedState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "travel-group", subgroup: "travel-subgroup")
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelTopicWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService
        )

        await sut.viewDidAppear()
        await Task.yield()

        #expect(mockTravelService._getGroupsCalled)
        if case .loaded = sut.viewState {
            // expected
        } else {
            Issue.record("Expected state to be .loaded after successful fetch")
        }
    }

    @Test
    func viewDidAppear_whenFetchFails_setsErrorState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelTopicWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService
        )

        await sut.viewDidAppear()
        await Task.yield()

        #expect(mockTravelService._getGroupsCalled)
        if case .error = sut.viewState {
            // expected
        } else {
            Issue.record("Expected state to be .error after failed fetch")
        }
    }

    @Test
    func openCountryList_setsSheetVisible_sendsAnalytic() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelTopicWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService
        )

        sut.openCountryList()

        let widgetEvent = mockAnalyticsService._trackedEvents.first

        #expect(widgetEvent?.params?["text"] as? String == "Add your countries")
        #expect(widgetEvent?.params?["section"] as? String == "Travel Abroad Notifications")
        #expect(widgetEvent?.params?["type"] as? String == "Widget")
        #expect(widgetEvent?.name == "Navigation")

        #expect(sut.isShowingList == true)
    }

    @Test
    func didDismissList_hidesSheet_andCallsDismissAction() {
        var dismissCalled = false
        let sut = TravelTopicWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            dismissAction: { dismissCalled = true }
        )

        sut.openCountryList()
        sut.didDismissList()

        #expect(sut.isShowingList == false)
        #expect(dismissCalled == true)
    }
}
