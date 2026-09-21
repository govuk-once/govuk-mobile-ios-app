import Foundation
import GovKit
import GovKitUI

class EditCountriesViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    struct SelectedCountry {
        let id: String
        let name: String
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var countriesSection = [GroupedListSection]()
    @Published private(set) var footerSection = [GroupedListSection]()
    @Published var isShowingList = false
    @Published var isShowingCountryDetails = false
    @Published var selectedCountry: SelectedCountry?
    @Published var selectedCountryNotificationEnabled = false
    @Published var isToggleLoading = false

    private let travelService: TravelServiceInterface
    private let notificationService: NotificationServiceInterface
    let analyticsService: AnalyticsServiceInterface
    private var allCountries: [Country] = []
    private var follewedCountries: Set<String> = []

    let title = String(
        localized: .Travel.editCountriesTitle
    )
    let description = String(
        localized: .Travel.editCountriesDescription
    )
    let followAnotherTitle = String(
        localized: .Travel.editCountriesFollowAnother
    )

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        notificationService: NotificationServiceInterface
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.notificationService = notificationService
    }

    lazy var countryListViewModel: CountryListViewModel = {
        CountryListViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            dismissAction: { [weak self] in
                self?.didDismissList()
            }
        )
    }()

    @MainActor
    func viewDidAppear() async {
        await fetchCountryList()
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    @MainActor
    func retryFetchCountryList() async {
        await fetchCountryList()
    }

    @MainActor
    func toggleNotifications(slug: String, enabled: Bool) async {
        travelService.toggleNotifications(slug: slug, enabled: enabled) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    // Update toggle logic
                    break
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }

    @MainActor
    func unfollowCountry(slug: String, enabled: Bool) async {
        travelService.unfollowCountry(
            slug: slug,
            currentNotificationsEnabled: enabled
        ) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    await self?.fetchCountryList()
                case .failure:
                    self?.viewState = .error
                }
            }
        }
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
                            self?.buildFooterRow()
                        }
                    }
                case .failure:
                    self?.viewState = .error
                }
            }
        }
    }

    private func buildRows(from groups: [TravelGroup], countries: [Country]) {
        self.allCountries = countries
        let countryMap = Dictionary(uniqueKeysWithValues: countries.map {
            ($0.slug.lowercased(), $0)
        })

        let rows = groups.compactMap { group -> SelectableRow? in
            guard let country = countryMap[group.group.lowercased()] else { return nil }
            self.follewedCountries.insert(group.group)

            return SelectableRow(
                id: group.group,
                title: country.name,
                imageName: "ellipsis",
                action: {
                    self.showCountryDetails(countryId: group.group, countryName: country.name)
                }
            )
        }

        countriesSection = [GroupedListSection(
            heading: nil,
            rows: rows,
            footer: nil
        )]

        self.viewState = .loaded
    }

    private func buildFooterRow() {
        let footerRow = [SelectableRow(
            id: "follow",
            title: self.followAnotherTitle,
            imageName: "plus.circle",
            action: { [weak self] in
                self?.openCountryList()
            }
        )]

        footerSection = [GroupedListSection(
            heading: nil, rows: footerRow, footer: nil)
        ]
    }

    func openCountryList() {
        isShowingList = true
    }

    func didDismissList() {
        isShowingList = false
    }

    private func showCountryDetails(countryId: String, countryName: String) {
        selectedCountry = SelectedCountry(id: countryId, name: countryName)
        selectedCountryNotificationEnabled = false
        isShowingCountryDetails = true
    }

    @MainActor
    func toggleNotifications(for countryId: String) async {
        isToggleLoading = true
        let newState = !selectedCountryNotificationEnabled

        // Make API call to update notification state
    }

    @MainActor
    func unfollowCountry(_ countryId: String) async {
        isToggleLoading = true

        // Make API call to unfollow the country
    }
}
