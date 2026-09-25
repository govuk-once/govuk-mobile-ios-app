import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
@MainActor
struct CountryListViewModelTests {

    @Test
    func dismissAction_executesClosure() {
        var didCallDismiss = false

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in
                didCallDismiss = true
            })

        viewModel.dismissAction(true)

        #expect(didCallDismiss == true)
    }

    @Test
    func trackScreen_createsCorrectEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            dismissAction: { _ in /*EmptyForTests*/ })

        let screen = CountryListView(viewModel: viewModel)
        viewModel.trackScreen(screen: screen)

        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingClass == screen.trackingClass)
    }

    @Test
    func viewDidAppear_whenFetchSucceeds_buildsSingleSortedSectionAndSetsLoadedState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        #expect(mockTravelService._getCountriesCalled)
        if case .loaded = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .loaded after a successful countries fetch")
        }
        #expect(viewModel.filteredSections.count == 1)

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 2)

        let firstRow = rows.first as? SelectableRow
        let secondRow = rows.dropFirst().first as? SelectableRow
        #expect(firstRow?.title == "Argentina")
        #expect(secondRow?.title == "Brazil")
    }

    @Test
    func viewDidAppear_whenFetchFails_setsErrorStateAndClearsSections() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .failure(.apiUnavailable)
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        #expect(mockTravelService._getCountriesCalled)
        if case .error = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .error after a failed countries fetch")
        }
        #expect(viewModel.filteredSections.isEmpty)
    }

    @Test
    func viewDidAppear_withEmptyCountries_setsEmptyState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        if case .empty = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .empty when countries fetch returns empty array")
        }
        #expect(viewModel.filteredSections.isEmpty)
    }

    @Test
    func searchText_filtersCountriesByName() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: []),
            Country(name: "Belgium", slug: "belgium", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "Brazil"

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 1)
        #expect((rows.first as? SelectableRow)?.title == "Brazil")
    }

    @Test
    func searchText_filtersCountriesBySynonyms() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "United Kingdom", slug: "uk", rawLastUpdate: "", synonyms: ["Great Britain", "UK"]),
            Country(name: "United States", slug: "usa", rawLastUpdate: "", synonyms: ["America", "US"])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "uk"

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 1)
        #expect((rows.first as? SelectableRow)?.title == "United Kingdom")
    }

    @Test
    func searchText_caseInsensitiveSearch() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "BRAZIL"

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 1)
        #expect((rows.first as? SelectableRow)?.title == "Brazil")
    }

    @Test
    func searchText_trimsWhitespace() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "   Bra    "

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 1)
        #expect((rows.first as? SelectableRow)?.title == "Brazil")
    }

    @Test
    func searchText_emptySearchShowsAllCountries() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "Brazil"
        #expect(viewModel.filteredSections.first?.rows.count == 1)

        viewModel.searchText = ""
        #expect(viewModel.filteredSections.first?.rows.count == 2)
    }

    @Test
    func searchText_noMatchesResultsInEmptyState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "NonExistentCountry"

        if case .empty = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .empty when search returns no results")
        }
        #expect(viewModel.filteredSections.isEmpty)
    }

    @Test
    func partialSearch_matchesCountriesByPrefix() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "British Virgin Islands", slug: "british virgin islands", rawLastUpdate: "", synonyms: ["bvi"]),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "Br"

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 2)
    }

    @Test
    func handleCountrySelection_whenNotificationOptInTrueAndNoConsent_showsPermissionScreen() {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        #expect(viewModel.showTravelAlertsPermission == true)
    }

    @Test
    func handleCountrySelection_whenNotificationOptInFalse_proceedsWithSelection() {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == "france")
    }

    @Test
    func handleCountrySelection_whenHasConsentAndOptIn_proceedsWithSelection() {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = true

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        #expect(mockTravelService._subscribeToGroupsCalled == true)
    }

    @Test
    func proceedWithCountrySelection_callsSubscribeToGroups() {
        let mockTravelService = MockTravelService()
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == country.slug)
    }

    @Test
    func subscribeToCountryAlerts_onSuccess_callsDismissAction() async {
        var didCallDismiss = false
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .success(())
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  didCallDismiss = true }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        mockTravelService._receivedSubscribeCompletion?(.success(()))

        await Task.yield()

        #expect(didCallDismiss == true)
    }

    @Test
    func subscribeToCountryAlerts_onSuccess_setsLoadingState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .success(())
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in /*EmptyForTests*/ }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        if case .loading = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .loading when subscription starts")
        }
    }

    @Test
    func subscribeToCountryAlerts_onFailure_doesCallDismissAction() async {
        var didCallDismiss = false
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .failure(.apiUnavailable)

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  didCallDismiss = true }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        mockTravelService._receivedSubscribeCompletion?(.failure(.apiUnavailable))

        await Task.yield()
        #expect(didCallDismiss == true)
    }

    @Test
    func subscribeToCountryAlerts_onFailure_callsErrorCallback() async {
        var didCallErrorCallback = false
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .failure(.apiUnavailable)

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in },
            errorCallback: { didCallErrorCallback = true }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        mockTravelService._receivedSubscribeCompletion?(.failure(.apiUnavailable))

        await Task.yield()
        #expect(didCallErrorCallback == true)
    }

    @Test
    func handleCountrySelection_tracksToggleAnalytics() {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService,
            dismissAction: { _ in }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        let events = mockAnalyticsService._trackedEvents
        #expect(events.count >= 1)
        let toggleEvent = events.first(where: { $0.params?["text"] as? String == "France" })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["section"] as? String == "Travel Abroad Notifications")
        #expect(toggleEvent?.params?["action"] as? String == "Add")
    }

    @Test
    func searchText_tracksSearchEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            dismissAction: { _ in }
        )

        viewModel.searchText = "France"
        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        let events = mockAnalyticsService._trackedEvents
        #expect(events.count >= 1)
        let searchEvent = events.first(where: { $0.name == "Search" })
        #expect(searchEvent != nil)
        #expect(searchEvent?.params?["text"] as? String == "France")
        #expect(searchEvent?.params?["section"] as? String == "country_search")
    }

    @Test
    func hasNotificationConsent_returnsTrueWhenServiceReturnsTrue() {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = true

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in }
        )

        #expect(viewModel.hasNotificationConsent == true)
    }

    @Test
    func hasNotificationConsent_returnsFalseWhenServiceReturnsFalse() {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in }
        )

        #expect(viewModel.hasNotificationConsent == false)
    }

    func subscribeToCountryAlerts_onFailure_setsLoadedStateAfterError() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .failure(.apiUnavailable)
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in /*EmptyForTests*/ }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        mockTravelService._receivedSubscribeCompletion?(.failure(.apiUnavailable))

        await Task.yield()

        if case .loaded = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .loaded after subscription failure")
        }
    }

    func countryListViewModel_initialisedWithDependencies() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        var dismissActionCalled = false
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissActionCalled = true },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        let countryListVM = sut.countryListViewModel

        #expect(countryListVM != nil)

        countryListVM.dismissAction(true)

        #expect(dismissActionCalled == true)
        #expect(sut.isShowingList == false)
    }

    @Test
    func retryFetchCountryList_whenFetchSucceeds_setsLoadedState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.retryFetchCountryList()
        await Task.yield()

        #expect(mockTravelService._getCountriesCalled)
        if case .loaded = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .loaded after successful retry fetch")
        }
        #expect(viewModel.filteredSections.count == 1)
    }

    @Test
    func retryFetchCountryList_whenFetchFails_setsErrorState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .failure(.apiUnavailable)
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.retryFetchCountryList()
        await Task.yield()

        #expect(mockTravelService._getCountriesCalled)
        if case .error = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .error after failed retry fetch")
        }
        #expect(viewModel.filteredSections.isEmpty)
    }

    @Test
    func selectedCountry_isSetWhenCountryActionInvoked() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        let rows = viewModel.filteredSections.first?.rows ?? []
        if let selectableRow = rows.first as? SelectableRow {
            selectableRow.action()
        }

        #expect(viewModel.selectedCountry?.name == "Brazil")
        #expect(viewModel.selectedCountry?.slug == "brazil")
    }

    @Test
    func createPermissionViewModel_returnsViewModelWithCorrectDetails() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            dismissAction: { _ in }
        )

        let permissionViewModel = viewModel.createPermissionViewModel()

        #expect(permissionViewModel.showImage == true)
        #expect(permissionViewModel.title == "Give permission")
        #expect(permissionViewModel.primaryButtonTitle == "Agree and continue")
        #expect(permissionViewModel.secondaryButtonTitle == "Not now")
    }

    @Test
    func createPermissionViewModel_completeAction_proceedsWithCountrySelection() {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.selectedCountry = country
        viewModel.showTravelAlertsPermission = true

        let permissionViewModel = viewModel.createPermissionViewModel()
        permissionViewModel.completeAction()

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == "france")
        #expect(viewModel.showTravelAlertsPermission == false)
        #expect(viewModel.selectedCountry == nil)
    }

    @Test
    func createPermissionViewModel_dismissAction_proceedsWithCountrySelectionWithoutConsent() {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            dismissAction: { _ in }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.selectedCountry = country
        viewModel.showTravelAlertsPermission = true

        let permissionViewModel = viewModel.createPermissionViewModel()
        permissionViewModel.dismissAction()

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == "france")
        #expect(viewModel.showTravelAlertsPermission == false)
        #expect(viewModel.selectedCountry == nil)
    }
}
