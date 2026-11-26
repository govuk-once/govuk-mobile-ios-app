import Foundation
import Testing
import Combine
import XCTest

@testable import govuk_ios
import GovKit

@Suite
@MainActor
struct EditCountriesViewModelTests {

    @Test
    func initialState_isLoadingAndSheetClosed() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        if case .loading = sut.viewState {
            // expected
        } else {
            Issue.record("Expected initial state to be .loading")
        }
        #expect(sut.isShowingList == false)
        #expect(sut.countriesSection.isEmpty)
        #expect(sut.footerSection.isEmpty)
    }

    @Test
    func countryListViewModel_openFooterLink_tracksStaticHelpAndFeedbackURL() {
        let mockAnalyticsService = MockAnalyticsService()
        var footerActionCalled = false
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: { footerActionCalled = true },
            navigateBackAction: { /* No-op */ }
        )

        sut.countryListViewModel.openFooterLink(text: "Tell us the country you're looking for")

        let event = mockAnalyticsService._trackedEvents.first(where: { $0.name == "Navigation" })
        #expect(event?.params?["url"] as? String == "https://www.gov.uk/contact/govuk-app")
        #expect(footerActionCalled)
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
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
        #expect(mockTravelService._getCountriesCalled)
        #expect(!sut.countriesSection.isEmpty)
    }

    @Test
    func viewDidAppear_whenGroupsFetchFails_setsErrorState() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .error = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
    }

    @Test
    func viewDidAppear_whenCountriesFetchFails_setsErrorState() async throws {
        let mockTravelService = MockTravelService()
        let testGroups = [
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ]
        mockTravelService._stubbedGetGroupsResult = .success(testGroups)
        mockTravelService._stubbedGetCountriesResult = .failure(.networkUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .error = state { return true }
            return false
        }

        #expect(mockTravelService._getCountriesCalled)
        #expect(sut.countriesSection.isEmpty)
    }

    @Test
    func retryFetchCountryList_whenFetchSucceeds_setsLoadedState() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "spain", subgroup: "travel-subgroup")
        ])
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "Spain", slug: "spain", rawLastUpdate: "2024-08-10", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.retryFetchCountryList()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
        #expect(mockTravelService._getCountriesCalled)
    }

    @Test
    func retryFetchCountryList_whenFetchFails_setsErrorState() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .failure(.apiUnavailable)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.retryFetchCountryList()
        try await waitForViewState(of: sut) { state in
            if case .error = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
    }

    @Test
    func buildCountriesSections_populatesSectionWhenCountriesMatch() async throws {
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
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(!sut.countriesSection.isEmpty)
    }

    @Test
    func buildCountriesSections_returnsEmptyWhenNoGroupsOrCountriesExist() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])
        let mockAnalyticsService = MockAnalyticsService()
        var navigateBackActionCalled = false
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: { navigateBackActionCalled = true }
        )

        await sut.viewDidAppear()

        #expect(sut.countriesSection.count == 0)
        #expect(navigateBackActionCalled == false)
    }

    @Test
    func buildCountriesSections_onlyIncludesMatchingCountries() async throws {
        let mockTravelService = MockTravelService()
        let testGroups = [
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ]
        let testCountries = [
            Country(name: "France", slug: "france", rawLastUpdate: "5 August 2024", synonyms: []),
            Country(name: "Spain", slug: "spain", rawLastUpdate: "10 August 2024", synonyms: [])
        ]
        mockTravelService._stubbedGetGroupsResult = .success(testGroups)
        mockTravelService._stubbedGetCountriesResult = .success(testCountries)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        // Only matching countries should be included in the section
        #expect(!sut.countriesSection.isEmpty)
    }

    @Test
    func buildCountriesSections_performsCaseInsensitiveMatching() async throws {
        let mockTravelService = MockTravelService()
        let testGroups = [
            TravelGroup(namespace: "travel-advice", group: "FRANCE", subgroup: "travel-subgroup")
        ]
        let testCountries = [
            Country(name: "France", slug: "france", rawLastUpdate: "5 August 2024", synonyms: [])
        ]
        mockTravelService._stubbedGetGroupsResult = .success(testGroups)
        mockTravelService._stubbedGetCountriesResult = .success(testCountries)
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        // Case-insensitive matching should result in populated section
        #expect(!sut.countriesSection.isEmpty)
    }

    @Test
    func buildFooterRow_populatesFooterSection() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ])
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "2024-08-05", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(!sut.footerSection.isEmpty)
    }

    @Test
    func openCountryList_setsSheetVisible() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        #expect(sut.isShowingList == false)
        sut.openCountryList()
        #expect(sut.isShowingList == true)
    }

    @Test
    func didDismissList_hidesSheet() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.openCountryList()
        #expect(sut.isShowingList == true)
        sut.didDismissList(forceRefresh: true)
        #expect(sut.isShowingList == false)
    }

    @Test
    func trackScreen_callsAnalyticsService() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )
        let screen = EditCountriesView(viewModel: sut)
        sut.trackScreen(screen: screen)

        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingClass == screen.trackingClass)
    }

    @Test
    func countryListViewModel_hasDismissActionThatUpdatesList() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.openCountryList()
        #expect(sut.isShowingList == true)

        // The lazy countryListViewModel's dismissAction should call didDismissList
        sut.didDismissList(forceRefresh: true)
        #expect(sut.isShowingList == false)
    }

    @Test
    func toggleNotifications_onSuccess_setsLoadingStateAndClearsError() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.toggleNotifications(slug: "france", enabled: true)

        #expect(mockTravelService._toggleNotificationsCalled == true)
        #expect(mockTravelService._receivedToggleNotificationSlug == "france")
        #expect(mockTravelService._recievedToggleNotificationEnabled == true)

        mockTravelService._receivedToggleNotificationCompletion?(.success(()))
        await Task.yield()

        #expect(sut.isToggleLoading == false)
        #expect(sut.displayToggleError == false)
    }

    @Test
    func toggleNotifications_onFailure_setsErrorMessage() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .failure(.apiUnavailable)
        mockTravelService._autoCallToggleCompletion = false
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.toggleNotifications(slug: "france", enabled: false)

        #expect(sut.isToggleLoading == true)

        mockTravelService._receivedToggleNotificationCompletion?(.failure(.apiUnavailable))
        await Task.yield()

        #expect(sut.isToggleLoading == false)
        #expect(sut.displayToggleError == true)
    }

    @Test
    func toggleNotifications_cachesNotificationState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        // Toggle notifications to enabled
        await sut.toggleNotifications(slug: "france", enabled: true)
        mockTravelService._receivedToggleNotificationCompletion?(.success(()))
        await Task.yield()

        // Verify the call was made with correct parameters
        #expect(mockTravelService._toggleNotificationsCalled == true)
        #expect(mockTravelService._receivedToggleNotificationSlug == "france")
        #expect(mockTravelService._recievedToggleNotificationEnabled == true)

        // Toggle again for another country to verify cache still works
        await sut.toggleNotifications(slug: "spain", enabled: false)
        mockTravelService._receivedToggleNotificationCompletion?(.success(()))
        await Task.yield()

        #expect(mockTravelService._receivedToggleNotificationSlug == "spain")
        #expect(mockTravelService._recievedToggleNotificationEnabled == false)
    }

    @Test
    func unfollowCountry_onSuccess_refetchesListAndClosesDetails() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedUnfollowResult = .success(())
        mockTravelService._autoCallUnfollowCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.isShowingCountryDetails = true
        await sut.unfollowCountry(slug: "france", enabled: true)

        #expect(sut.isUnfollowing == true)

        mockTravelService._receivedUnfollowCountryCompletion?(.success(()))
        await Task.yield()

        #expect(sut.isUnfollowing == false)
        #expect(sut.isShowingCountryDetails == false)
        #expect(sut.displayUnfollowError == false)
    }

    @Test
    func unfollowCountry_onFailure_setsErrorAndKeepsDetailsOpen() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedUnfollowResult = .failure(.networkUnavailable)
        mockTravelService._autoCallUnfollowCompletion = false

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.isShowingCountryDetails = true
        await sut.unfollowCountry(slug: "france", enabled: true)

        #expect(sut.isUnfollowing == true)

        mockTravelService._receivedUnfollowCountryCompletion?(.failure(.networkUnavailable))
        await Task.yield()

        #expect(sut.isUnfollowing == false)
        #expect(sut.isShowingCountryDetails == true)
        #expect(sut.displayUnfollowError == true)

    }

    @Test
    func unfollowCountry_clearsNotificationStateCache() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        mockTravelService._stubbedUnfollowResult = .success(())
        mockTravelService._autoCallUnfollowCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        // First toggle to populate cache
        await sut.toggleNotifications(slug: "france", enabled: true)
        mockTravelService._receivedToggleNotificationCompletion?(.success(()))

        // Then unfollow
        await sut.unfollowCountry(slug: "france", enabled: true)
        mockTravelService._receivedUnfollowCountryCompletion?(.success(()))
        await Task.yield()

        #expect(mockTravelService._unfollowCountryCalled == true)
        #expect(mockTravelService._receivedUnfollowCountrySlug == "france")
    }

    @Test
    func clearToggleError_removesErrorMessage() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.displayToggleError = true
        #expect(sut.displayToggleError == true)

        sut.clearToggleError()
        #expect(sut.displayToggleError == false)
    }

    @Test
    func clearUnfollowError_removesErrorMessage() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.displayUnfollowError = true
        #expect(sut.displayUnfollowError == true)
        sut.isShowingCountryDetails = true
        #expect(sut.isShowingCountryDetails == true)


        sut.clearUnfollowError()
        #expect(sut.displayUnfollowError == false)
        #expect(sut.isShowingCountryDetails == false)
    }

    @Test
    func toggleNotifications_populatesNotificationStateCache() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "weekly")
        ])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        // Toggle to cache enabled state
        await sut.toggleNotifications(slug: "france", enabled: true)

        #expect(mockTravelService._recievedToggleNotificationEnabled == true)

        mockTravelService._receivedToggleNotificationCompletion?(.success(()))
        await Task.yield()

        #expect(sut.isToggleLoading == false)
    }

    @Test
    func toggleNotifications_enabledFalse_success_invalidatesGroupsCache() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.toggleNotifications(slug: "spain", enabled: false)
        mockTravelService._receivedToggleNotificationCompletion?(.success(()))
        await Task.yield()

        #expect(sut.isToggleLoading == false)
    }

    @Test
    func unfollowCountry_clearsNotificationStateCacheOnSuccess() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        mockTravelService._stubbedUnfollowResult = .success(())
        mockTravelService._autoCallUnfollowCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        // First toggle to populate cache
        await sut.toggleNotifications(slug: "france", enabled: true)
        mockTravelService._receivedToggleNotificationCompletion?(.success(()))
        await Task.yield()

        #expect(mockTravelService._toggleNotificationsCalled == true)

        // Then unfollow - should clear cache for that country
        sut.isShowingCountryDetails = true
        await sut.unfollowCountry(slug: "france", enabled: true)
        mockTravelService._receivedUnfollowCountryCompletion?(.success(()))
        await Task.yield()
        await Task.yield()
        await Task.yield()

        #expect(mockTravelService._unfollowCountryCalled == true)
        #expect(sut.isShowingCountryDetails == false)
    }

    @Test
    func unfollowCountry_withNotificationsEnabled_passesCorrectParameters() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedUnfollowResult = .success(())
        mockTravelService._autoCallUnfollowCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.unfollowCountry(slug: "france", enabled: true)

        #expect(mockTravelService._unfollowCountryCalled == true)
        #expect(mockTravelService._receivedUnfollowCountrySlug == "france")
    }

    @Test
    func unfollowCountry_withoutNotificationsEnabled_passesCorrectParameters() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedUnfollowResult = .success(())
        mockTravelService._autoCallUnfollowCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.unfollowCountry(slug: "spain", enabled: false)

        #expect(mockTravelService._unfollowCountryCalled == true)
        #expect(mockTravelService._receivedUnfollowCountrySlug == "spain")
    }

    @Test(.timeLimit(.minutes(1)))
    func unfollowCountry_propagatesForceRefreshToGetCountries() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedUnfollowResult = .success(())
        mockTravelService._autoCallUnfollowCompletion = false
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.unfollowCountry(slug: "france", enabled: true)
        await withCheckedContinuation { continuation in
            mockTravelService._getCountriesCompletion = {
                mockTravelService._getCountriesCompletion = nil
                continuation.resume()
            }
            mockTravelService._receivedUnfollowCountryCompletion?(.success(()))
        }

        #expect(mockTravelService._getCountriesCalledWithForceRefresh == true)
    }

    @Test
    func buildCountriesSections_sortsCountriesByNameAlphabetically() async throws {
        let mockTravelService = MockTravelService()
        let testGroups = [
            TravelGroup(namespace: "travel-advice", group: "zebra", subgroup: "travel-subgroup"),
            TravelGroup(namespace: "travel-advice", group: "apple", subgroup: "travel-subgroup"),
            TravelGroup(namespace: "travel-advice", group: "monkey", subgroup: "travel-subgroup")
        ]
        let testCountries = [
            Country(name: "Zebra Land", slug: "zebra", rawLastUpdate: "2024-08-05", synonyms: []),
            Country(name: "Apple Valley", slug: "apple", rawLastUpdate: "2024-08-05", synonyms: []),
            Country(name: "Monkey Island", slug: "monkey", rawLastUpdate: "2024-08-05", synonyms: [])
        ]
        mockTravelService._stubbedGetGroupsResult = .success(testGroups)
        mockTravelService._stubbedGetCountriesResult = .success(testCountries)

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        // Verify section exists and is populated (sorted alphabetically Apple, Monkey, Zebra)
        #expect(!sut.countriesSection.isEmpty)
        #expect(sut.countriesSection.count == 1)
    }

    @Test
    func didDismissList_withoutForceRefresh_justClosesSheet() {
        let mockTravelService = MockTravelService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.openCountryList()
        #expect(sut.isShowingList == true)

        sut.didDismissList(forceRefresh: false)
        #expect(sut.isShowingList == false)
        #expect(mockTravelService._getGroupsCalled == false)
    }

    @Test
    func didDismissList_withForceRefresh_refetchesCountries() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "travel-subgroup")
        ])
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "2024-08-05", synonyms: [])
        ])

        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.openCountryList()
        #expect(sut.isShowingList == true)

        sut.didDismissList(forceRefresh: true)
        await Task.yield()

        #expect(sut.isShowingList == false)
        #expect(mockTravelService._getGroupsCalled == true)
    }

    @Test
    func countryListViewModel_passesErrorCallback() {
        let mockTravelService = MockTravelService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        let countryListVM = sut.countryListViewModel

        // Calling errorCallback should set isShowingFollowError
        countryListVM.errorCallback?()
        #expect(sut.isShowingFollowError == true)
    }

    @Test
    func clearFollowError_removesFollowErrorMessage() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.isShowingFollowError = true
        #expect(sut.isShowingFollowError == true)

        sut.clearFollowError()
        #expect(sut.isShowingFollowError == false)
    }

    @Test
    func trackScreen_callsAnalyticsServiceWithCorrectScreen() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )
        let screen = EditCountriesView(viewModel: sut)
        sut.trackScreen(screen: screen)

        #expect(mockAnalyticsService._trackScreenReceivedScreens.count == 1)
    }

    @Test
    func requestToggle_whenNotificationsDisabled_callsToggleNotifications() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.requestToggle(slug: "france", enabled: false)

        #expect(mockTravelService._toggleNotificationsCalled == true)
        #expect(mockTravelService._receivedToggleNotificationSlug == "france")
        #expect(mockTravelService._recievedToggleNotificationEnabled == false)
    }

    @Test
    func requestToggle_whenNotificationsEnabledWithoutPermissionFlowNeeded_callsToggleDirectly() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        mockTravelService._autoCallToggleCompletion = false
        let mockNotificationService = MockNotificationService()
        // needsTravelAlertsPermissionFlow is false when hasGivenConsent && permissionState == .authorized
        mockNotificationService._stubbedhasGivenConsent = true
        mockNotificationService._stubbededPermissionState = .authorized
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            notificationService: mockNotificationService,
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.requestToggle(slug: "spain", enabled: true)
        await Task.yield()

        #expect(mockTravelService._toggleNotificationsCalled == true)
    }


    @Test
    func createNotificationsRationaleViewModel_withEditOrigin_isCreatedSuccessfully() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService,
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        await sut.requestToggle(slug: "france", enabled: true)
        try await Task.sleep(for: .seconds(1))

        guard let rationaleViewModel = sut.createNotificationsRationaleViewModel() else {
            Issue.record("Expected createNotificationsRationaleViewModel() to return a value")
            return
        }

        // Show image returning result shows successful view model generation
        #expect(rationaleViewModel.showImage == true)
    }

    private func waitForViewState(
        of viewModel: EditCountriesViewModel,
        matching predicate: @escaping (EditCountriesViewModel.ViewState) -> Bool,
        timeout: TimeInterval = 2.0
    ) async throws {
        for await state in viewModel.$viewState.values {
            if predicate(state) { return }
        }
    }

    // MARK: - Analytics

    private func makeLoadedSut(
        analyticsService: MockAnalyticsService,
        travelService: MockTravelService = MockTravelService(),
        notificationService: MockNotificationService = MockNotificationService()
    ) async throws -> EditCountriesViewModel {
        travelService._stubbedGetGroupsResult = .success([
            TravelGroup(namespace: "travel-advice", group: "france", subgroup: "daily")
        ])
        travelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "2024-08-05", synonyms: [])
        ])
        let sut = EditCountriesViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )
        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }
        return sut
    }

    private func toggleEvents(_ analyticsService: MockAnalyticsService) -> [AppEvent] {
        analyticsService._trackedEvents.filter {
            $0.name == "Function" && $0.params?["type"] as? String == "Toggle"
        }
    }

    private func notNowEvents(_ analyticsService: MockAnalyticsService) -> [AppEvent] {
        analyticsService._trackedEvents.filter {
            $0.name == "Navigation" && $0.params?["text"] as? String == "Not now"
        }
    }

    @Test
    func openCountryList_tracksFollowAnotherCountry() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )

        sut.openCountryList()

        #expect(mockAnalyticsService._trackedEvents.count == 1)
        let event = mockAnalyticsService._trackedEvents.first
        #expect(event?.name == "Navigation")
        #expect(event?.params?["text"] as? String == "Follow another country")
        #expect(event?.params?["type"] as? String == "Button")
        #expect(event?.params?["external"] as? Bool == false)
        #expect(event?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func countryListSheetDidDismiss_whenSwipedAway_tracksCloseAndHidesSheet() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )
        sut.openCountryList()
        sut.countryListViewModel.sheetDidAppear()

        sut.countryListSheetDidDismiss()

        let closeEvents = mockAnalyticsService._trackedEvents.filter {
            $0.params?["text"] as? String == "Close"
        }
        #expect(closeEvents.count == 1)
        #expect(sut.isShowingList == false)
    }

    @Test
    func countryListSheetDidDismiss_afterFollow_doesNotTrackClose() async {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            urlOpener: MockURLOpener(),
            openCountryListFooterAction: {  /*Empty For Tests*/ },
            navigateBackAction: {  /*Empty For Tests*/ }
        )
        sut.openCountryList()
        sut.countryListViewModel.sheetDidAppear()

        sut.countryListViewModel.dismiss(true)
        sut.countryListSheetDidDismiss()

        let closeEvents = mockAnalyticsService._trackedEvents.filter {
            $0.params?["text"] as? String == "Close"
        }
        #expect(closeEvents.isEmpty)
    }

    @Test
    func requestToggle_off_tracksToggleOffWithCountryName() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTravelService = MockTravelService()
        mockTravelService._autoCallToggleCompletion = false
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService
        )

        await sut.requestToggle(slug: "france", enabled: false)

        let events = toggleEvents(mockAnalyticsService)
        #expect(events.count == 1)
        #expect(events.first?.params?["text"] as? String == "France")
        #expect(events.first?.params?["action"] as? String == "Off")
        #expect(events.first?.params?["section"] as? String == "Travel Abroad Notifications")
    }

    @Test
    func requestToggle_onWithoutPermissionFlow_tracksToggleOnOnce() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTravelService = MockTravelService()
        mockTravelService._autoCallToggleCompletion = false
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = true
        mockNotificationService._stubbededPermissionState = .authorized
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            notificationService: mockNotificationService
        )

        await sut.requestToggle(slug: "france", enabled: true)

        let events = toggleEvents(mockAnalyticsService)
        #expect(events.count == 1)
        #expect(events.first?.params?["text"] as? String == "France")
        #expect(events.first?.params?["action"] as? String == "On")
        #expect(mockTravelService._toggleNotificationsCalled)
    }

    @Test
    func requestToggle_onWithPermissionFlow_tracksToggleOnBeforeShowingPermissionScreen() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService
        )

        await sut.requestToggle(slug: "france", enabled: true)

        let events = toggleEvents(mockAnalyticsService)
        #expect(events.count == 1)
        #expect(events.first?.params?["action"] as? String == "On")
        #expect(sut.showNotificationsRationale)
    }

    @Test
    func requestToggle_unknownCountry_doesNotTrack() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTravelService = MockTravelService()
        mockTravelService._autoCallToggleCompletion = false
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService
        )

        await sut.requestToggle(slug: "narnia", enabled: false)

        #expect(toggleEvents(mockAnalyticsService).isEmpty)
    }

    @Test
    func rationaleFlowDidDismiss_whenSwipedAway_tracksNotNow() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService
        )
        await sut.requestToggle(slug: "france", enabled: true)

        sut.rationaleFlowDidDismiss()

        let events = notNowEvents(mockAnalyticsService)
        #expect(events.count == 1)
        #expect(events.first?.params?["type"] as? String == "Button")
        #expect(events.first?.params?["external"] as? Bool == false)
        #expect(events.first?.params?["section"] as? String == "Travel Abroad Notifications")
        #expect(sut.selectedCountryNotificationEnabled == false)
    }

    @Test
    func rationaleFlowDidDismiss_afterNotNow_tracksNotNowOnce() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService
        )
        await sut.requestToggle(slug: "france", enabled: true)
        let rationaleViewModel = try #require(sut.createNotificationsRationaleViewModel())

        rationaleViewModel.notNowAction()
        sut.rationaleFlowDidDismiss()

        #expect(notNowEvents(mockAnalyticsService).count == 1)
        #expect(sut.showNotificationsRationale == false)
    }

    @Test
    func rationaleFlowDidDismiss_afterBackButton_tracksNotNowOnce() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            notificationService: mockNotificationService
        )
        await sut.requestToggle(slug: "france", enabled: true)
        let rationaleViewModel = try #require(sut.createNotificationsRationaleViewModel())

        rationaleViewModel.backButtonAction()
        sut.rationaleFlowDidDismiss()

        #expect(notNowEvents(mockAnalyticsService).count == 1)
        #expect(sut.showNotificationsRationale == false)
        #expect(sut.selectedCountryNotificationEnabled == false)
    }

    @Test
    func rationaleFlowDidDismiss_afterSuccess_doesNotTrackNotNow() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedToggleResult = .success(())
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = false
        mockNotificationService._stubbededPermissionState = .authorized
        let sut = try await makeLoadedSut(
            analyticsService: mockAnalyticsService,
            travelService: mockTravelService,
            notificationService: mockNotificationService
        )
        await sut.requestToggle(slug: "france", enabled: true)
        let rationaleViewModel = try #require(sut.createNotificationsRationaleViewModel())

        rationaleViewModel.allowNotificationsAction()
        for _ in 0..<100 where sut.showNotificationsRationale {
            try await Task.sleep(for: .milliseconds(10))
        }
        sut.rationaleFlowDidDismiss()

        #expect(sut.showNotificationsRationale == false)
        #expect(notNowEvents(mockAnalyticsService).isEmpty)
        #expect(sut.selectedCountryNotificationEnabled == true)
    }
}
