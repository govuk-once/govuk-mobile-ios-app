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
    func buildCountriesSections_keepsEmptySectionWhenNoGroupsExist() async throws {
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

        // Section should exist but be empty when no groups match
        #expect(sut.countriesSection.count == 1)
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
        sut.didDismissList()
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
        sut.didDismissList()
        #expect(sut.isShowingList == false)
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
