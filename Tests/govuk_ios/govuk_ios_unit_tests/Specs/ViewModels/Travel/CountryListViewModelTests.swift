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
        viewModel.onGetNotificationAlertTap(country, text: "France")

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
        viewModel.onNotNowAlertTap(country, text: "France")

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
        viewModel.onGetNotificationAlertTap(country, text: "France")

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
    func onCountryTap_tracksToggleAnalytics() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        (viewModel.filteredSections.first?.rows.first as? SelectableRow)?.action()

        let toggleEvent = mockAnalyticsService._trackedEvents.first(where: {
            $0.params?["text"] as? String == "France" && $0.params?["action"] as? String == "Add"
        })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["section"] as? String == "Travel Abroad Notifications")
        #expect(toggleEvent?.params?["action"] as? String == "Add")
    }

    @Test
    func onCountryTap_withSearchText_tracksSearchEvent() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "France"
        (viewModel.filteredSections.first?.rows.first as? SelectableRow)?.action()

        let searchEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Search" })
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

    @Test
    func subscribeToCountryAlerts_onFailure_callsDismissActionWithFalse() async {
        var dismissCalled = false
        var dismissWithForceRefresh = true
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedSubscribeResult = .failure(.apiUnavailable)
        mockTravelService._autoCallSubscribeCompletion = false

        let viewModel = makeViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            dismissAction: { forceRefresh in
                dismissCalled = true
                dismissWithForceRefresh = forceRefresh
            }
        )

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.proceedWithCountrySelection(country, true)

        mockTravelService._receivedSubscribeCompletion?(.failure(.apiUnavailable))

        await Task.yield()

        #expect(dismissCalled == true)
        #expect(dismissWithForceRefresh == false)
    }

    @Test
    func countryListViewModel_initialisedWithDependencies() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        var dismissActionCalled = false
        let actions = CountryListViewModel.Actions(
            dismissAction: { _ in dismissActionCalled = true },
            openFooterLinkAction: { },
            openExternalURLAction: { _ in }
        )

        let viewModel = CountryListViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService,
            urlOpener: MockURLOpener(),
            actions: actions,
            footerLinkURLString: nil
        )

        viewModel.dismiss(true)

        #expect(dismissActionCalled == true)
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
        viewModel.onGetNotificationAlertTap(Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: []), text: "France")

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
        viewModel.onGetNotificationAlertTap(country, text: "Spain")

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
        let testURL = URL(string: "https://www.gov.uk/government/publications/govuk-test-app-privacy-notice/govuk-test-app-privacy-notice")!
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
        viewModel.onGetNotificationAlertTap(country, text: "Italy")

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
        viewModel.onGetNotificationAlertTap(country, text: "Portugal")
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
        viewModel.onGetNotificationAlertTap(country, text: "Greece")
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
        viewModel.onGetNotificationAlertTap(country, text: "Poland")

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
        viewModel.onGetNotificationAlertTap(country, text: "Sweden")

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
        viewModel.onGetNotificationAlertTap(country, text: "Norway")
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
        viewModel.onGetNotificationAlertTap(country, text: "Finland")
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
        viewModel.onNotNowAlertTap(country, text: "Denmark")

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

        viewModel.openFooterLink(text: "HelpAndFeedback")

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

        viewModel.openFooterLink(text: "HelpAndFeedback")

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

        viewModel.openFooterLink(text: "HelpAndFeedback")

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)
        let buttonNavEvent = events.first(where: { $0.params?["text"] as? String == "HelpAndFeedback" })
        #expect(buttonNavEvent != nil)
        #expect(buttonNavEvent?.params?["url"] as? URL == nil)
        #expect(buttonNavEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func onCountryTap_withSearchText_tracksToggleAndSearchAnalytics() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "France"
        (viewModel.filteredSections.first?.rows.first as? SelectableRow)?.action()

        let toggleEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Function" })
        let searchEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Search" })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["section"] as? String == "Travel Abroad Notifications")
        #expect(searchEvent != nil)
        #expect(searchEvent?.params?["text"] as? String == "France")
    }

    @Test
    func onCountryTap_withoutSearchText_tracksOnlyToggleAnalytics() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        #expect(viewModel.searchText.isEmpty)
        (viewModel.filteredSections.first?.rows.first as? SelectableRow)?.action()

        let toggleEvent = mockAnalyticsService._trackedEvents.first(where: {
            $0.params?["text"] as? String == "France" && $0.params?["action"] as? String == "Add"
        })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["section"] as? String == "Travel Abroad Notifications")
        let searchEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Search" })
        #expect(searchEvent == nil)
    }

    @Test
    func resetNotificationsRationaleFlow_clearsShowNotificationsRationale() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(notificationService: mockNotificationService)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country, text: "France")

        try await Task.sleep(for: .seconds(1))
        #expect(viewModel.showNotificationsRationale == true)

        viewModel.resetNotificationsRationaleFlow()

        #expect(viewModel.showNotificationsRationale == false)
    }

    @Test
    func openFooterLink_tracksAnalyticsWithCorrectText() {
        let mockAnalyticsService = MockAnalyticsService()
        let testURLString = "https://www.gov.uk/feedback"

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

        viewModel.openFooterLink(text: "Feedback")

        let events = mockAnalyticsService._trackedEvents
        #expect(!events.isEmpty)

        let buttonNavEvent = events.first(where: {
            $0.name == "Navigation" && $0.params?["type"] as? String == "Button"
        })
        #expect(buttonNavEvent != nil)
        #expect(buttonNavEvent?.params?["text"] as? String == "Feedback")
        #expect(buttonNavEvent?.params?["external"] as? Bool == true)
        #expect(buttonNavEvent?.params?["url"] as? String == testURLString)
        #expect(buttonNavEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func onGetNotificationAlertTap_tracksWidgetNavigationEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(analyticsService: mockAnalyticsService)

        let country = Country(name: "Spain", slug: "spain", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country, text: "Spain")

        try await Task.sleep(for: .seconds(1))

        let navEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Navigation" })
        #expect(navEvent != nil)
        #expect(navEvent?.params?["text"] as? String == "Spain")
        #expect(navEvent?.params?["type"] as? String == "Widget")
        #expect(navEvent?.params?["external"] as? Bool == false)
        #expect(navEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func onNotNowAlertTap_tracksWidgetNavigationEvent() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(analyticsService: mockAnalyticsService)

        let country = Country(name: "Italy", slug: "italy", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country, text: "Italy")

        try await Task.sleep(for: .seconds(1))

        let navEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Navigation" })
        #expect(navEvent != nil)
        #expect(navEvent?.params?["text"] as? String == "Italy")
        #expect(navEvent?.params?["type"] as? String == "Widget")
        #expect(navEvent?.params?["external"] as? Bool == false)
        #expect(navEvent?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func selectedCountry_isSetWhenCountryActionInvoked_andDetailsAvailable() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Germany", slug: "germany", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = makeViewModel(travelService: mockTravelService)

        await viewModel.viewDidAppear()
        await Task.yield()

        let rows = viewModel.filteredSections.first?.rows ?? []
        if let selectableRow = rows.first as? SelectableRow {
            selectableRow.action()
        }

        #expect(viewModel.selectedCountry?.name == "Germany")
        #expect(viewModel.selectedCountry?.slug == "germany")
    }

    @Test
    func createNotificationsRationaleViewModel_withEditOrigin_createsViewModelForEditFlow() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(notificationService: mockNotificationService)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country, text: "France")

        try await Task.sleep(for: .seconds(1))

        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        #expect(permissionViewModel.showImage == true)
        #expect(!permissionViewModel.title.isEmpty)
        #expect(!permissionViewModel.body.isEmpty)
    }

    @Test
    func dismissSheetAction_clearsRationaleState() async throws {
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let viewModel = makeViewModel(notificationService: mockNotificationService)

        let country = Country(name: "Germany", slug: "germany", rawLastUpdate: "", synonyms: [])
        viewModel.onGetNotificationAlertTap(country, text: "Germany")

        try await Task.sleep(for: .seconds(1))
        #expect(viewModel.showNotificationsRationale == true)

        guard let permissionViewModel = viewModel.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        permissionViewModel.dismissSheetAction()

        #expect(viewModel.showNotificationsRationale == false)
    }

    // MARK: - T3: onCountryTap event ordering

    @Test
    func onCountryTap_tracksToggleThenSearch_inOrder() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "Fra"
        (viewModel.filteredSections.first?.rows.first as? SelectableRow)?.action()

        let events = mockAnalyticsService._trackedEvents
        let functionIndex = events.firstIndex(where: { $0.name == "Function" })
        let searchIndex = events.firstIndex(where: { $0.name == "Search" })
        #expect(functionIndex != nil)
        #expect(searchIndex != nil)
        #expect(functionIndex! < searchIndex!)
        #expect(events[searchIndex!].params?["text"] as? String == "Fra")
        #expect(events[searchIndex!].params?["section"] as? String == "country_search")
    }

    @Test
    func onNotNowAlertTap_doesNotTrackToggleOrSearch() async {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(analyticsService: mockAnalyticsService)

        let country = Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        viewModel.onNotNowAlertTap(country, text: "Not now")

        await Task.yield()

        let navEvents = mockAnalyticsService._trackedEvents.filter { $0.name == "Navigation" }
        let toggleEvents = mockAnalyticsService._trackedEvents.filter { $0.name == "Function" }
        let searchEvents = mockAnalyticsService._trackedEvents.filter { $0.name == "Search" }
        #expect(navEvents.count == 1)
        #expect(toggleEvents.isEmpty)
        #expect(searchEvents.isEmpty)
    }

    @Test
    func onCountryTap_thenCancel_stillTracksToggle() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        (viewModel.filteredSections.first?.rows.first as? SelectableRow)?.action()
        viewModel.selectedCountry = nil

        let toggleEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Function" })
        #expect(toggleEvent != nil)
        #expect(toggleEvent?.params?["text"] as? String == "France")
    }

    // MARK: - T4: Search submit

    @Test
    func onSearchSubmitted_withText_tracksTypedSearchEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(analyticsService: mockAnalyticsService)

        viewModel.searchText = "Spain"
        viewModel.onSearchSubmitted()

        let searchEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Search" })
        #expect(searchEvent != nil)
        #expect(searchEvent?.params?["type"] as? String == "typed")
        #expect(searchEvent?.params?["section"] as? String == "country_search")
        #expect(searchEvent?.params?["text"] as? String == "Spain")
    }

    @Test
    func onSearchSubmitted_withEmptyText_tracksNothing() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(analyticsService: mockAnalyticsService)

        viewModel.searchText = ""
        viewModel.onSearchSubmitted()

        #expect(mockAnalyticsService._trackedEvents.isEmpty)
    }

    // MARK: - T5: PII redaction

    @Test
    func searchTracking_redactsPII() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "SW1A 1AA", slug: "sw1a1aa", rawLastUpdate: "", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = makeViewModel(travelService: mockTravelService, analyticsService: mockAnalyticsService)

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "SW1A 1AA"
        viewModel.onSearchSubmitted()

        let searchEvent = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Search" })
        #expect(searchEvent != nil)
        #expect(searchEvent?.params?["text"] as? String == "[postcode]")
    }
}
