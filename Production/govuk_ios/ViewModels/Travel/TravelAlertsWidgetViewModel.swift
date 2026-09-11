import Foundation
import UIKit
import CoreData
import GovKit

final class TravelAlertsWidgetViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded(groupedList: [GroupedListSection])
        case empty
        case error
    }

    // Drives .sheet(isPresented:) in the widget view
    @Published var isShowingList = false
    @Published private(set) var viewState: ViewState = .loading

    private let travelService: TravelServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let linkAction: () -> Void
    private let dismissAction: () -> Void
    private let openURLAction: (URL) -> Void

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        linkAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void,
        openURLAction: @escaping (URL) -> Void
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.linkAction = linkAction
        self.dismissAction = dismissAction
        self.openURLAction = openURLAction
    }

    lazy var countryListViewModel: CountryListViewModel = {
        CountryListViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            countrySelectedAction: { _ in
                // Selection flow will be implented in a future change.
            },
            dismissAction: {
                self.dismissAction()
                self.didDismissList()
            }
        )
    }()

    @MainActor
    func viewDidAppear() async {
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
                            self?.buildSections(from: groups, countries: countries)
                        }
                    }
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }

    private func buildSections(from groups: [TravelGroup], countries: [Country]) {
        let countryMap = Dictionary(uniqueKeysWithValues: countries.map {
            ($0.slug.lowercased(), $0)
        })

        let rows = groups.compactMap { group -> LinkRow? in
            guard let country = countryMap[group.group.lowercased()] else { return nil }

            let url = URL(string: "https://www.gov.uk/foreign-travel-advice/\(country.slug.lowercased())")

            return LinkRow(
                id: group.group,
                title: country.name,
                body: String(localized: .Travel.travelAlertLastUpdated(
                    formattedDate: country.formattedLastUpdate
                )),
                showLinkImage: false,
                action: { [weak self] in
                    guard let url else { return }
                    self?.openURLAction(url)
                }
            )
        }

        if rows.isEmpty {
            self.viewState = .empty
        } else {
            self.viewState = .loaded(groupedList: [
                GroupedListSection(
                    heading: nil,
                    rows: rows,
                    footer: nil
                )
            ])
        }
    }

    func openCountryList() {
        let event = AppEvent.widgetNavigation(
            text: "Add your countries",
            external: false,
            params: ["section": "Travel Abroad Notifications"]
        )
        analyticsService.track(event: event)
        isShowingList = true
    }

    func openExternalURL(_ url: URL) {
        openURLAction(url)
    }

    func didDismissList() {
        isShowingList = false
        dismissAction()
    }
}
