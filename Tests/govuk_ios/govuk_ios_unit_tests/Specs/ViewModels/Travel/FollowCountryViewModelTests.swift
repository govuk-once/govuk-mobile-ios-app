import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

@Suite
@MainActor
struct FollowCountryViewModelTests {

    @Test
    func dismissAction_executesClosure() {
        var didCallDismiss = false

        let viewModel = FollowCountryViewModel(
            travelService: MockTravelService(),
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: {
            didCallDismiss = true
        })

        viewModel.dismissAction()

        #expect(didCallDismiss == true)
    }

    @Test
    func trackScreen_createsCorrectEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = FollowCountryViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ })

        let screen = FollowCountryView(viewModel: viewModel)
        viewModel.trackScreen(screen: screen)

        let screens = mockAnalyticsService._trackScreenReceivedScreens
        #expect(screens.count == 1)
        #expect(screens.first?.trackingClass == screen.trackingClass)
    }

    @Test
    func viewDidAppear_whenFetchSucceeds_buildsSingleSortedSectionAndSetsLoadedState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
    func selectingARow_executesCountrySelectedAction() async {
        let mockTravelService = MockTravelService()
        let selectedCountry = Country(
            country: "Argentina",
            slug: "argentina",
            lastUpdate: "",
            synonyms: []
        )
        mockTravelService._stubbedGetCountriesResult = .success([selectedCountry])

        var capturedCountry: Country?
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { country in
                capturedCountry = country
            },
            dismissAction: { /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        let firstRow = viewModel.filteredSections.first?.rows.first as? SelectableRow
        firstRow?.action()

        #expect(capturedCountry == selectedCountry)
    }

    @Test
    func searchText_filtersCountriesByName() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: []),
            Country(country: "Belgium", slug: "belgium", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
            Country(country: "United Kingdom", slug: "uk", lastUpdate: "", synonyms: ["Great Britain", "UK"]),
            Country(country: "United States", slug: "usa", lastUpdate: "", synonyms: ["America", "US"])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
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
            Country(country: "Brazil", slug: "brazil", lastUpdate: "", synonyms: []),
            Country(country: "British Virgin Islands", slug: "british virgin islands", lastUpdate: "", synonyms: ["bvi"]),
            Country(country: "Argentina", slug: "argentina", lastUpdate: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            analyticsService: MockAnalyticsService(),
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        viewModel.searchText = "Br"

        let rows = viewModel.filteredSections.first?.rows ?? []
        #expect(rows.count == 2)
    }
}
