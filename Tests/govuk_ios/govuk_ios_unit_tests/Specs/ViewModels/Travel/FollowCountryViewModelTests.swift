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
            countrySelectedAction: { _ in /*EmptyForTests*/ },
            dismissAction: {
            didCallDismiss = true
        })

        viewModel.dismissAction()

        #expect(didCallDismiss == true)
    }

    @Test
    func viewDidAppear_whenFetchSucceeds_buildsSingleSortedSectionAndSetsLoadedState() async {
        let mockTravelService = MockTravelService()
        mockTravelService._stubbedGetCountriesResult = .success([
            Country(slug: "brazil", country: "Brazil", lastUpdated: "", synonyms: []),
            Country(slug: "argentina", country: "Argentina", lastUpdated: "", synonyms: [])
        ])
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
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
        #expect(viewModel.sections.count == 1)

        let rows = viewModel.sections.first?.rows ?? []
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
        #expect(viewModel.sections.isEmpty)
    }

    @Test
    func selectingARow_executesCountrySelectedAction() async {
        let mockTravelService = MockTravelService()
        let selectedCountry = Country(
            slug: "argentina",
            country: "Argentina",
            lastUpdated: "",
            synonyms: []
        )
        mockTravelService._stubbedGetCountriesResult = .success([selectedCountry])

        var capturedCountry: Country?
        let viewModel = FollowCountryViewModel(
            travelService: mockTravelService,
            countrySelectedAction: { country in
                capturedCountry = country
            },
            dismissAction: { /*EmptyForTests*/ }
        )

        await viewModel.viewDidAppear()
        await Task.yield()

        let firstRow = viewModel.sections.first?.rows.first as? SelectableRow
        firstRow?.action()

        #expect(capturedCountry == selectedCountry)
    }
}
