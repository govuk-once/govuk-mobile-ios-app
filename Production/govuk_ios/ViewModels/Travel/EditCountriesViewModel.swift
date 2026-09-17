import Foundation
import GovKit
import GovKitUI

class EditCountriesViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var countriesSection = [GroupedListSection]()
    @Published private(set) var footerSection = [GroupedListSection]()

    private let travelService: TravelServiceInterface
    let analyticsService: AnalyticsServiceInterface

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
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

        travelService.getGroups(forceRefresh: false) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let groups):
                    self?.travelService.getCountries(
                        forceRefresh: false
                    ) { [weak self] countriesResult in
                        Task { @MainActor in
                            let countries = (try? countriesResult.get()) ?? []
                            self?.buildRows(from: groups, countries: countries)
                        }
                    }
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }

    private func buildRows(from groups: [TravelGroup], countries: [Country]) {
        let countryMap = Dictionary(uniqueKeysWithValues: countries.map {
            ($0.slug.lowercased(), $0)
        })

        let rows = groups.compactMap { group -> SelectableRow? in
            guard let country = countryMap[group.group.lowercased()] else { return nil }

            return SelectableRow(
                id: group.group,
                title: country.name,
                imageName: "ellipsis",
                action: {
                    // Implement logic in upcoming work
                }
            )
        }

        if rows.isEmpty {

        }
        countriesSection = [GroupedListSection(
            heading: nil,
            rows: rows,
            footer: nil
        )]
    }

    private func buildFooterRow() {
        let footerRow = [SelectableRow(
            id: "follow",
            title: "Follow a country",
            imageName: "plus.circle",
            action: {
                // Navigate to country list
            }
        )]

        footerSection = [GroupedListSection(
            heading: nil, rows: footerRow, footer: nil)
        ]
    }
}
