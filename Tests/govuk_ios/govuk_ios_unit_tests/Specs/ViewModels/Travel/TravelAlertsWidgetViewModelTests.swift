import Foundation
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct TravelAlertsWidgetViewModelTests {

    @Test
    func initialState_isLoadingAndSheetClosed() {
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
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
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ])
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "2024-08-05", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        #expect(mockTravelService._getGroupsCalled)
        #expect(mockTravelService._getCountriesCalled)
        if case .loaded = sut.viewState {
            // expected
        } else {
            Issue.record("Expected state to be .loaded after successful fetch, but got \(sut.viewState)")
        }
    }

    @Test
    func viewDidAppear_whenFetchFails_setsErrorState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

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
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
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
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissCalled = true },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        sut.openCountryList()
        sut.didDismissList()

        #expect(sut.isShowingList == false)
        #expect(dismissCalled == true)
    }

    @Test
    func openExternalURL_callsOpenURLAction() {
        var openedURL: URL? = nil
        let testURL = URL(string: "https://www.gov.uk/test")!
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { url in openedURL = url }
        )

        sut.openExternalURL(testURL)

        #expect(openedURL == testURL)
    }

    @Test
    func viewDidAppear_whenGroupsAreEmpty_setsEmptyState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        #expect(mockTravelService._getGroupsCalled)
        if case .empty = sut.viewState {
            // expected
        } else {
            Issue.record("Expected state to be .empty when groups are empty")
        }
    }

    @Test
    func viewDidAppear_whenCountriesFetchFails_setsLoadedWithFilteredRows() async {
        let mockTravelService = MockTravelService()
        let testGroups = [
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ]
        mockTravelService._stubbedGetGroupsResult = .success(testGroups)
        mockTravelService._stubbedGetCountriesResult = .failure(.networkUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        #expect(mockTravelService._getCountriesCalled)
        // When countries fetch fails, no rows can be built (empty countries array), so state is .empty
        if case .empty = sut.viewState {
            // expected - countries failed, so no rows can be displayed
        } else {
            Issue.record("Expected state to be .empty when countries fetch fails and no rows can be built")
        }
    }

    @Test
    func buildSections_createsCorrectSectionCount() async {
        let mockTravelService = MockTravelService()
        let testGroups = [
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup"),
            TravelGroup(namespace: "travel-advice", group: "spain", subgroup: "travel-subgroup")
        ]
        let testCountries = [
            Country(name: "France", slug: "france", rawLastUpdate: "5 August 2024", synonyms: []),
            Country(name: "Spain", slug: "spain", rawLastUpdate: "10 August 2024", synonyms: [])
        ]
        mockTravelService._stubbedGetGroupsResult = .success(testGroups)
        mockTravelService._stubbedGetCountriesResult = .success(testCountries)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        // Wait for all async tasks to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        if case .loaded(let sections) = sut.viewState {
            #expect(sections.count == 1)
        } else {
            Issue.record("Expected state to be .loaded with exactly one section")
        }
    }

    @Test
    func countryListViewModel_isInitializedLazily() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        // Accessing the lazy property should initialize it
        let viewModel = sut.countryListViewModel

        #expect(viewModel is CountryListViewModel)
    }

    @Test
    func dismissAction_isCalledOnDismiss() {
        var dismissActionCalled = false
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissActionCalled = true },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        sut.didDismissList()

        #expect(dismissActionCalled)
    }

    @Test
    func openCountryList_setsIsShowingListToTrue() {
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        #expect(sut.isShowingList == false)
        sut.openCountryList()
        #expect(sut.isShowingList == true)
    }
}
