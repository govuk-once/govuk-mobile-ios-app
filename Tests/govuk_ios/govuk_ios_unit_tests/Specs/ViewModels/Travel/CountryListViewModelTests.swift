import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
@MainActor
struct CountryListViewModelTests {

    private func makeViewModel(
        travelService: TravelServiceInterface = MockTravelService(),
        analyticsService: AnalyticsServiceInterface = MockAnalyticsService(),
        notificationService: NotificationServiceInterface = MockNotificationService(),
        dismissAction: @escaping (Bool) -> Void = { _ in },
        openFooterLinkAction: @escaping () -> Void = { },
        openExternalURLAction: @escaping (URL) -> Void = { _ in },
        footerLinkURLString: String? = nil,
        errorCallback: (() -> Void)? = nil
    ) -> CountryListViewModel {
        let actions = CountryListViewModel.Actions(
            dismissAction: dismissAction,
            openFooterLinkAction: openFooterLinkAction,
            openExternalURLAction: openExternalURLAction
        )
        return CountryListViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            urlOpener: MockURLOpener(),
            actions: actions,
            footerLinkURLString: footerLinkURLString,
            errorCallback: errorCallback
        )
    }

    @Test
    func dismissAction_executesClosure() {
        var didCallDismiss = false
        let viewModel = makeViewModel(
            dismissAction: { _ in didCallDismiss = true }
        )

        viewModel.dismiss(true)

        #expect(didCallDismiss == true)
    }

    @Test
    func trackScreen_createsCorrectEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: mockAnalyticsService, notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "Br"

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 2)
    }

    @Test
    func handleCountrySelection_whenNotificationOptInTrueAndNoConsent_showsPermissionScreen() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        #expect(viewModel.showNotificationsRationale == true)
    }

    @Test
    func handleCountrySelection_whenNotificationOptInFalse_proceedsWithSelection() async throws {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: mockNotificationService)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == "france")
    }

    @Test
    func handleCountrySelection_whenHasConsentAndOptIn_proceedsWithSelection() async throws {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = true
        mockNotificationService._stubbededPermissionState = .authorized

        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: mockNotificationService)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        #expect(mockTravelService._subscribeToGroupsCalled == true)
    }

    @Test
    func proceedWithCountrySelection_callsSubscribeToGroups() {
        let mockTravelService = MockTravelService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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

        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService(), dismissAction: { _ in  didCallDismiss = true })

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

        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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

        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService(), dismissAction: { _ in  didCallDismiss = true })

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
            urlOpener: MockURLOpener(),
            actions: CountryListViewModel.Actions(
                dismissAction: { _ in },
                openFooterLinkAction: { /*Empty For Tests*/ },
                openExternalURLAction: { _ in /*Empty For Tests*/ }
            ),
            errorCallback: { didCallErrorCallback = true }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        mockTravelService._receivedSubscribeCompletion?(.failure(.apiUnavailable))

        await Task.yield()
        #expect(didCallErrorCallback == true)
    }

    @Test
    func handleCountrySelection_tracksToggleAnalytics() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: mockAnalyticsService, notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        let events = mockAnalyticsService._trackedEvents
        #expect(events.count >= 1)
        let toggleEvent = events.first(where: { $0.params?["text"] as? String == "France" })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["section"] as? String == "Travel Abroad Notifications")
        #expect(toggleEvent?.params?["action"] as? String == "Add")
    }

    @Test
    func searchText_tracksSearchEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: mockAnalyticsService, notificationService: MockNotificationService(), dismissAction: { _ in })

        viewModel.searchText = "France"
        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        try await Task.sleep(for: .seconds(1))
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

        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        #expect(viewModel.hasNotificationConsent == true)
    }

    @Test
    func hasNotificationConsent_returnsFalseWhenServiceReturnsFalse() {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false

        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        #expect(viewModel.hasNotificationConsent == false)
    }

    func subscribeToCountryAlerts_onFailure_setsLoadedStateAfterError() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .failure(.apiUnavailable)
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
            feedbackURL: URL(string: "https://example.com/feedback")!,
            urlOpener: MockURLOpener(),
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissActionCalled = true },
            editAction: { /*Empty For Tests*/ },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        let countryListVM = sut.countryListViewModel

        countryListVM.dismiss(true)

        #expect(dismissActionCalled == true)
        #expect(sut.isShowingList == false)
    }

    @Test
    func retryFetchCountryList_whenFetchSucceeds_setsLoadedState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: MockNotificationService())

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
    func createNotificationsRationaleViewModel_returnsViewModelWithCorrectDetails() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: mockAnalyticsService, notificationService: mockNotificationService, dismissAction: { _ in })

        // Trigger the permission flow by selecting a country without consent
        viewModel.onGetNotificationAlertTap(Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: []))

        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        #expect(permissionViewModel.showImage == true)
        #expect(permissionViewModel.title == "Give permission")
        #expect(permissionViewModel.primaryButtonTitle == "Agree and continue")
        #expect(permissionViewModel.secondaryButtonTitle == "Not now")
    }

    @Test
    func createNotificationsRationaleViewModel_returnsNilWhenNoCountryPending() {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: mockAnalyticsService, notificationService: mockNotificationService, dismissAction: { _ in })

        let permissionViewModel = viewModel.createNotificationsRationaleViewModel()
        #expect(permissionViewModel == nil)
    }

    @Test
    func createNotificationsRationaleViewModel_dismissSheetActionClearsPermissionState() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: mockAnalyticsService, notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Spain", slug: "spain", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        #expect(viewModel.showNotificationsRationale == true)

        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        permissionViewModel.dismissSheetAction()

        #expect(viewModel.showNotificationsRationale == false)
    }

    @Test
    func createNotificationsRationaleViewModel_usesProvidedOpenExternalURLAction() async throws {
        var capturedURL: URL?
        let testURL = URL(string: "https://www.gov.uk/government/publications/govuk-app-privacy-notice-how-we-use-your-data")!
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService,
            dismissAction: { _ in },
            openExternalURLAction: { url in capturedURL = url }
        )

        let country = Country(name: "Italy", slug: "italy", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        permissionViewModel.openPrivacyPolicy()

        #expect(capturedURL == testURL)
    }

    @Test
    func createNotificationsRationaleViewModel_includesCorrectButtonTitles() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Portugal", slug: "portugal", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)
        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        #expect(permissionViewModel.primaryButtonTitle == "Agree and continue")
        #expect(permissionViewModel.secondaryButtonTitle == "Not now")
    }

    @Test
    func createNotificationsRationaleViewModel_afterDismissSheetAction_returnsNil() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Greece", slug: "greece", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)
        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        permissionViewModel.dismissSheetAction()

        let secondPermissionViewModel = viewModel.createNotificationsRationaleViewModel()
        #expect(secondPermissionViewModel == nil)
    }

    @Test
    func createNotificationsRationaleViewModel_hasBodyAndTitleText() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Poland", slug: "poland", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        #expect(!permissionViewModel.body.isEmpty)
        #expect(!permissionViewModel.title.isEmpty)
    }

    @Test
    func createNotificationsRationaleViewModel_hasPrivacyPolicyLink() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Sweden", slug: "sweden", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        #expect(!permissionViewModel.privacyPolicyLinkTitle.isEmpty)
    }

    @Test
    func createNotificationsRationaleViewModel_doesNotHaveDisplayNotificationSettingsAlert() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Norway", slug: "norway", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)
        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        #expect(permissionViewModel.displayNotificationSettingsAlert == false)
    }

    @Test
    func createNotificationsRationaleViewModel_initialViewStateIsIdle() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: MockTravelService(), analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Finland", slug: "finland", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)
        try await Task.sleep(for: .seconds(1))
        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        if case .idle = permissionViewModel.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .idle initially")
        }
    }

    @Test
    func onNotNowAlertTap_withoutConsent_subscribesToCountry() async throws {
        let mockTravelService = MockTravelService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: MockAnalyticsService(), notificationService: mockNotificationService, dismissAction: { _ in })

        let country = Country(name: "Denmark", slug: "denmark", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        try await Task.sleep(for: .seconds(1))
        #expect(mockTravelService._subscribeToGroupsCalled == true)
        #expect(mockTravelService._receivedSubscribeSlug == "denmark")
    }

    @Test
    func openFooterLink_callsOpenFooterLinkAction() {
        var didCallFooterLinkAction = false

        let viewModel = makeViewModel(
            openFooterLinkAction: { didCallFooterLinkAction = true }
        )

        viewModel.openFooterLink()

        #expect(didCallFooterLinkAction == true)
    }

    @Test
    func openFooterLink_tracksButtonNavigationEventWithFooterLinkURL() {
        let testURLString = "https://www.gov.uk/helpandfeedback"
        let mockAnalyticsService = MockAnalyticsService()

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            actions: CountryListViewModel.Actions(
                dismissAction: { _ in },
                openFooterLinkAction: { },
                openExternalURLAction: { _ in }
            ),
            footerLinkURLString: testURLString
        )

        viewModel.openFooterLink()

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)
        let buttonNavEvent = events.first(where: { $0.params?["text"] as? String == "HelpAndFeedback" })
        #expect(buttonNavEvent != nil)
        #expect(buttonNavEvent?.params?["url"] as? String == testURLString)
        #expect(buttonNavEvent?.params?["external"] as? Bool == true)
        #expect(buttonNavEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func openFooterLink_withNilFooterLinkURL_tracksEventWithNilURL() {
        let mockAnalyticsService = MockAnalyticsService()

        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            actions: CountryListViewModel.Actions(
                dismissAction: { _ in },
                openFooterLinkAction: { },
                openExternalURLAction: { _ in }
            ),
            footerLinkURLString: nil
        )

        viewModel.openFooterLink()

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)
        let buttonNavEvent = events.first(where: { $0.params?["text"] as? String == "HelpAndFeedback" })
        #expect(buttonNavEvent != nil)
        #expect(buttonNavEvent?.params?["url"] as? URL == nil)
        #expect(buttonNavEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func handleCountrySelection_withNotificationOptInTrue_tracksToggleAndSearchAnalytics() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let mockTravelService = MockTravelService()

        let viewModel = makeViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService
        )

        // Set search text before selection
        viewModel.searchText = "France"

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country)

        try await Task.sleep(for: .seconds(1))

        // Should have tracked toggle and search events
        let events = mockAnalyticsService._trackedEvents
        #expect(events.count >= 2)

        // Verify toggle event
        let toggleEvent = events.first(where: { $0.params?["text"] as? String == "France" })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["section"] as? String == "Travel Abroad Notifications")

        // Verify search event
        let searchEvent = events.first(where: { $0.name == "Search" })
        #expect(searchEvent != nil)
        #expect(searchEvent?.params?["text"] as? String == "France")
    }

    @Test
    func handleCountrySelection_withoutSearchText_tracksOnlyToggleAnalytics() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let mockTravelService = MockTravelService()

        let viewModel = makeViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService
        )

        // No search text set
        #expect(viewModel.searchText.isEmpty)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country)

        try await Task.sleep(for: .seconds(1))

        // Should have only toggle event
        let events = mockAnalyticsService._trackedEvents
        let toggleEvent = events.first(where: { $0.params?["text"] as? String == "France" })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["action"] as? String == "Add")

        // No search event tracked
        let searchEvent = events.first(where: { $0.name == "Search" })
        #expect(searchEvent == nil)
    }
}
