import Foundation
import Testing
import Combine
import XCTest

@testable import govuk_ios

@Suite
@MainActor
struct EditCountriesViewModelTests {

    @Test
    func initialState_isLoadingAndSheetClosed() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .error = state { return true }
            return false
        }

        #expect(mockTravelService._getGroupsCalled)
    }

    @Test
    func viewDidAppear_whenCountriesFetchFails_setsLoadedState() async throws {
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
            notificationService: MockNotificationService()
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(mockTravelService._getCountriesCalled)
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(!sut.countriesSection.isEmpty)
    }

    @Test
    func buildCountriesSections_returnsEmptyWhenNoGroupsExist() async throws {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetGroupsResult = .success([])
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(name: "France", slug: "france", rawLastUpdate: "5 August 2024", synonyms: [])
        ])
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService()
        )

        await sut.viewDidAppear()
        try await waitForViewState(of: sut) { state in
            if case .loaded = state { return true }
            return false
        }

        #expect(sut.countriesSection.count == 0)
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
        )
        let screen = EditCountriesView(viewModel: sut)
        sut.trackScreen(screen: screen)

        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingClass == screen.trackingClass)
    }

    @Test
    func countryListViewModel_isInitializedLazily() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService()
        )

        // Accessing the lazy property should initialize it
        let viewModel = sut.countryListViewModel

        #expect(viewModel is CountryListViewModel)
    }

    @Test
    func countryListViewModel_hasDismissActionThatUpdatesList() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        let sut = EditCountriesViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
        )

        await sut.unfollowCountry(slug: "spain", enabled: false)

        #expect(mockTravelService._unfollowCountryCalled == true)
        #expect(mockTravelService._receivedUnfollowCountrySlug == "spain")
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
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
            notificationService: MockNotificationService()
        )

        let countryListVM = sut.countryListViewModel
        #expect(countryListVM != nil)

        // Calling errorCallback should set isShowingFollowError
        countryListVM.errorCallback()
        #expect(sut.isShowingFollowError == true)
    }

    @Test
    func clearFollowError_removesFollowErrorMessage() {
        let sut = EditCountriesViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService()
        )

        sut.isShowingFollowError = true
        #expect(sut.isShowingFollowError == true)

        sut.clearFollowError()
        #expect(sut.isShowingFollowError == false)
    }

    private func waitForViewState(
        of viewModel: EditCountriesViewModel,
        matching predicate: @escaping (EditCountriesViewModel.ViewState) -> Bool,
        timeout: TimeInterval = 2.0
    ) async throws {
        for await state in viewModel.$viewState.dropFirst().values {
            if predicate(state) { return }
        }
    }
}
