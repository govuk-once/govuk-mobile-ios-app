import Foundation
import GovKitUI
import GovKit

class CountryListViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var sections = [GroupedListSection]()
    @Published var searchText = ""

    private let travelService: TravelServiceInterface
    let analyticsService: AnalyticsServiceInterface
    private let countrySelectedAction: (Country) -> Void
    let dismissAction: () -> Void

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        countrySelectedAction: @escaping (Country) -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.countrySelectedAction = countrySelectedAction
        self.dismissAction = dismissAction
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    @MainActor
    func viewDidAppear() async {
        await fetchCountryList()
    }

    @MainActor
    func retryFetchCountryList() async {
        await fetchCountryList()
    }

    @MainActor
    private func fetchCountryList() async {
        viewState = .loading

        travelService.getCountries(forceRefresh: false) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let countries):
                    self?.sections = self?.buildSections(from: countries) ?? []
                    self?.viewState = .loaded
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }

    private func buildSections(from countries: [Country]) -> [GroupedListSection] {
        let sortedCountries = countries.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        let rows = sortedCountries.map { country in
            SelectableRow(
                id: country.slug,
                title: country.name,
                action: { [countrySelectedAction] in
                    countrySelectedAction(country)
                }
            )
        }

        guard rows.isEmpty == false else {
            return []
        }

        return [
            GroupedListSection(
                heading: nil,
                rows: rows,
                footer: nil
            )
        ]
    }
}
