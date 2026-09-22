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
        let country: Country
        let subgroup: String
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published private(set) var countriesSection = [GroupedListSection]()
    @Published private(set) var footerSection = [GroupedListSection]()
    @Published var isShowingList = false
    @Published var isShowingCountryDetails = false
    @Published var selectedCountry: SelectedCountry?
    @Published var selectedCountryNotificationEnabled = false
    @Published var isToggleLoading = false
    @Published var isUnfollowing = false
    @Published var toggleError: String?
    @Published var unfollowError: String?

    private let travelService: TravelServiceInterface
    private let notificationService: NotificationServiceInterface
    let analyticsService: AnalyticsServiceInterface
    private var allCountries: [Country] = []
    private var follewedCountries: Set<String> = []
    private var notificationStateCache: [String: Bool] = [:]

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

    @MainActor
    lazy var countryListViewModel: CountryListViewModel = {
        CountryListViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            dismissAction: { [weak self] forceRefresh in
                Task {
                    self?.didDismissList(forceRefresh: forceRefresh)
                }
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
        isToggleLoading = true
        notificationStateCache[slug] = enabled
        travelService.toggleNotifications(slug: slug, enabled: enabled) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.isToggleLoading = false
                case .failure:
                    self?.isToggleLoading = false
                    self?.toggleError = "Failed to update notifications"
                }
            }
        }
    }

    @MainActor
    func unfollowCountry(slug: String, enabled: Bool) async {
        isUnfollowing = true
        travelService.unfollowCountry(
            slug: slug,
            currentNotificationsEnabled: enabled
        ) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.notificationStateCache.removeValue(forKey: slug)
                    await self?.fetchCountryList(forceRefresh: true)
                    self?.isUnfollowing = false
                    self?.isShowingCountryDetails = false
                case .failure:
                    self?.isUnfollowing = false
                    self?.unfollowError = "Failed to unfollow country"
                }
            }
        }
    }

    @MainActor
    private func fetchCountryList(forceRefresh: Bool = false) async {
        viewState = .loading
        countriesSection = []

        travelService.getGroups(forceRefresh: forceRefresh) { [weak self] result in
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
                    self.showCountryDetails(country: country, subgroup: group.subgroup)
                }
            )
        }
        .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        if rows.count > 0 {
            countriesSection = [GroupedListSection(
                heading: nil,
                rows: rows,
                footer: nil
            )]
        }

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

    func didDismissList(forceRefresh: Bool) {
        isShowingList = false
        if forceRefresh {
            Task {
                await fetchCountryList(forceRefresh: true)
            }
        }
    }

    func clearToggleError() {
        toggleError = nil
    }

    private func showCountryDetails(country: Country, subgroup: String) {
        selectedCountry = SelectedCountry(country: country, subgroup: subgroup)
        if let cachedState = notificationStateCache[country.slug] {
            selectedCountryNotificationEnabled = cachedState
        } else {
            selectedCountryNotificationEnabled = subgroup.lowercased() == "daily"
        }
        isShowingCountryDetails = true
    }
}
