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
    func trackSearchInput_createsCorrectAnalyticsEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            dismissAction: { _ in  /*EmptyForTests*/ }
        )

        viewModel.trackSearchInput(text: "France")

        let events = mockAnalyticsService._trackedEvents
        #expect(events.count == 1)
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
        viewModel.handleCountrySelection(country, notificationOptIn: true)

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
        viewModel.handleCountrySelection(country, notificationOptIn: false)

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
        viewModel.handleCountrySelection(country, notificationOptIn: true)

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
        viewModel.proceedWithCountrySelection(country)

        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == country.slug)
    }

    @Test
    func subscribeToCountryAlerts_onSuccess_callsDismissAction() {
        var didCallDismiss = false
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .success(())

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { _ in  didCallDismiss = true }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country)

        mockTravelService._receivedSubscribeCompletion?(.success(()))

        #expect(didCallDismiss == true)
    }

    @Test
    func subscribeToCountryAlerts_onFailure_doesNotCallDismissAction() {
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
        viewModel.proceedWithCountrySelection(country)

        mockTravelService._receivedSubscribeCompletion?(.failure(.apiUnavailable))

        #expect(didCallDismiss == false)
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
}
