import Foundation
import Testing
import Combine
import XCTest

@testable import govuk_ios

@Suite
@MainActor
struct TravelAlertsWidgetViewModelTests {

    @Test
    func initialState_isLoadingAndSheetClosed() {
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
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
    func initialState_errorShowingFalse() {
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        #expect(sut.isShowingError == false)
    }

    @Test
    func viewDidAppear_whenFetchSucceeds_setsLoadedState() async throws {
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
        #expect(mockTravelService._getCountriesCalled)
    }

    @Test
    func viewDidAppear_loadsData() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ])
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "2024-08-05", synonyms: [])
        ])
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
        #expect(mockTravelService._getCountriesCalled)
    }

    @Test
    func viewDidAppear_whenFetchFails_setsErrorState() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .error = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
    }

    @Test
    func openCountryList_setsSheetVisible_sendsAnalytic() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissCalled = true },
            editAction: { /*Empty For Tests*/ },
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { url in openedURL = url }
        )

        sut.openExternalURL(testURL)

        #expect(openedURL == testURL)
    }

    @Test
    func viewDidAppear_whenGroupsAreEmpty_setsEmptyState() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .empty = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
    }

    @Test
    func viewDidAppear_whenCountriesFetchFails_setsEmptyState() async throws {
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .empty = state { return true }
            return false
        }

        #expect(mockTravelService._getCountriesCalled)
    }

    @Test
    func buildSections_createsCorrectSectionCount() async throws {
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded(let sections) = state {
                return sections.count == 1
            }
            return false
        }
    }

    @Test
    func countryListViewModel_isInitializedLazily() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissActionCalled = true },
            editAction: { /*Empty For Tests*/ },
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
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        #expect(sut.isShowingList == false)
        sut.openCountryList()
        #expect(sut.isShowingList == true)
    }

    @Test
    func countryListViewModel_hasErrorCallback() {
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        let viewModel = sut.countryListViewModel
        #expect(viewModel is CountryListViewModel)

        // Calling errorCallback should set isShowingError
        viewModel.errorCallback()
        #expect(sut.isShowingError == true)
    }

    @Test
    func openEditCountries_callsEditAction() {
        var editActionCalled = false
        let sut = TravelAlertsWidgetViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { /*Empty For Tests*/ },
            editAction: { editActionCalled = true },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        sut.openEditCountries()

        #expect(editActionCalled == true)
    }

    private func waitForViewState(
        of viewModel: TravelAlertsWidgetViewModel,
        matching predicate: @escaping (TravelAlertsWidgetViewModel.ViewState) -> Bool,
        timeout: TimeInterval = 2.0
    ) async throws {
        for await state in viewModel.$viewState.dropFirst().values {
            if predicate(state) { return }
        }
    }
}
