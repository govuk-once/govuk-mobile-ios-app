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
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ })

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
        let viewModel = CountryListViewModel(
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
            name: "Argentina",
            slug: "argentina",
            rawLastUpdate: "",
            synonyms: []
        )
        mockTravelService._stubbedGetCountriesResult = .success([selectedCountry])

        var capturedCountry: Country?
        let viewModel = CountryListViewModel(
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
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: []),
            Country(name: "Belgium", slug: "belgium", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
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
            Country(name: "United Kingdom", slug: "uk", rawLastUpdate: "", synonyms: ["Great Britain", "UK"]),
            Country(name: "United States", slug: "usa", rawLastUpdate: "", synonyms: ["America", "US"])
        ])
        let viewModel = CountryListViewModel(
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
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
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
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
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
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
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
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
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
            Country(name: "Brazil", slug: "brazil", rawLastUpdate: "", synonyms: []),
            Country(name: "British Virgin Islands", slug: "british virgin islands", rawLastUpdate: "", synonyms: ["bvi"]),
            Country(name: "Argentina", slug: "argentina", rawLastUpdate: "", synonyms: [])
        ])
        let viewModel = CountryListViewModel(
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

    @Test
    func trackSearchInput_tracksSearchEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        let searchTerm = "United Kingdom"
        viewModel.trackSearchInput(text: searchTerm)

        let events = mockAnalyticsService._trackedEvents
        #expect(events.count == 1)
        #expect(events.first?.name == "Search")
    }

    @Test
    func trackSearchInput_includesSearchTextInParams() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        let searchTerm = "Brazil"
        viewModel.trackSearchInput(text: searchTerm)

        let events = mockAnalyticsService._trackedEvents
        let textParam = events.first?.params?["text"] as? String
        #expect(textParam == searchTerm)
    }

    @Test
    func trackSearchInput_usesTypedInvocationType() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        viewModel.trackSearchInput(text: "test")

        let events = mockAnalyticsService._trackedEvents
        let typeParam = events.first?.params?["type"] as? String
        #expect(typeParam == "typed")
    }

    @Test
    func trackSearchInput_includesSectionInParams() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        viewModel.trackSearchInput(text: "test")

        let events = mockAnalyticsService._trackedEvents
        let typeParam = events.first?.params?["section"] as? String
        #expect(typeParam == "country_search")
    }

    @Test
    func trackSearchInput_withSpecialCharacters_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        let searchTerm = "test@#$%&*()"
        viewModel.trackSearchInput(text: searchTerm)

        let events = mockAnalyticsService._trackedEvents
        let textParam = events.first?.params?["text"] as? String
        #expect(textParam == searchTerm)
    }

    @Test
    func trackSearchInput_multipleInvocations_tracksAllEvents() {
        let mockAnalyticsService = MockAnalyticsService()
        let viewModel = CountryListViewModel(
            travelService: MockTravelService(),
            analyticsService: mockAnalyticsService,
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: { /*EmptyForTests*/ }
        )

        viewModel.trackSearchInput(text: "first")
        viewModel.trackSearchInput(text: "second")
        viewModel.trackSearchInput(text: "third")

        let events = mockAnalyticsService._trackedEvents
        #expect(events.count == 3)
        #expect((events[0].params?["text"] as? String) == "first")
        #expect((events[1].params?["text"] as? String) == "second")
        #expect((events[2].params?["text"] as? String) == "third")
    }

    func countryListViewModel_initialisedWithDependencies() {
        let mockTravelService = MockTravelService()
        let mockAnalyticsService = MockAnalyticsService()
        var dismissActionCalled = false
        let sut = TravelAlertsWidgetViewModel(
            travelService: mockTravelService,
            analyticsService: mockAnalyticsService,
            linkAction: { /*Empty For Tests*/ },
            dismissAction: { dismissActionCalled = true },
            openURLAction: { _ in /*Empty For Tests*/ }
        )

        let countryListVM = sut.countryListViewModel

        #expect(countryListVM != nil)

        countryListVM.dismissAction()

        #expect(dismissActionCalled == true)
        #expect(sut.isShowingList == false)
    }
}
