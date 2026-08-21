import Foundation
import GovKitUI
import GovKit

class FollowCountryViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var sections = [GroupedListSection]()
    @Published var searchText = ""

    private let travelService: TravelServiceInterface
    private let countrySelectedAction: (Country) -> Void
    let dismissAction: () -> Void

    init(
        travelService: TravelServiceInterface,
        countrySelectedAction: @escaping (Country) -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.countrySelectedAction = countrySelectedAction
        self.dismissAction = dismissAction
    }

    @MainActor
    func viewDidAppear() async {
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
            $0.country.localizedCaseInsensitiveCompare($1.country) == .orderedAscending
        }

        let rows = sortedCountries.map { country in
            // Update Row to be a new custom SelectableRow
            NavigationRow(
                id: country.slug,
                title: country.country,
                body: nil,
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
