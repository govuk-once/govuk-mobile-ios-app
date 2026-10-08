import Foundation
import GovKitUI
import GovKit

class CountryListViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case empty
        case error
    }

    struct Actions {
        let dismissAction: (Bool) -> Void
        let openFooterLinkAction: (URL) -> Void
        let openExternalURLAction: (URL) -> Void
    }

    @Published private(set) var viewState: ViewState = .loading
    @Published var searchText = "" {
        didSet {
            updateFilteredSections()
        }
    }
    @Published private(set) var filteredSections = [GroupedListSection]()
    @Published var selectedCountry: Country?
    @Published var showTravelAlertsPermission = false
    private var countryForPermissionFlow: Country?

    private var allCountries: [Country] = []
    private let travelService: TravelServiceInterface
    let analyticsService: AnalyticsServiceInterface
    private let notificationService: NotificationServiceInterface
    private let urlOpener: URLOpener
    private let actions: Actions
    let errorCallback: (() -> Void)?
    private let footerLinkURL: URL

    var hasNotificationConsent: Bool {
        notificationService.hasGivenConsent
    }

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        notificationService: NotificationServiceInterface,
        urlOpener: URLOpener,
        actions: Actions,
        errorCallback: (() -> Void)? = nil,
        footerLinkURL: URL
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.notificationService = notificationService
        self.urlOpener = urlOpener
        self.actions = actions
        self.errorCallback = errorCallback
        self.footerLinkURL = footerLinkURL
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    private func trackSearchInput(text: String) {
        let searchEvent = AppEvent.searchTerm(term: text, type: .typed, section: "country_search")
        analyticsService.track(event: searchEvent)
    }

    private func trackToggleFunction(countryName: String) {
        let toggleEvent = AppEvent.toggleAction(
            text: countryName,
            section: "Travel Abroad Notifications",
            action: "Add"
        )
        analyticsService.track(event: toggleEvent)
    }

    func onGetNotificationAlertTap(_ country: Country) {
        handleCountrySelection(country, notificationOptIn: true)
    }

    func onNotNowAlertTap(_ country: Country) {
        handleCountrySelection(country, notificationOptIn: false)
    }

    private func handleCountrySelection(_ country: Country, notificationOptIn: Bool) {
        trackToggleFunction(countryName: country.name)
        if !searchText.isEmpty {
            trackSearchInput(text: searchText)
        }
        // Given global notifications are off and user is attempting to optIn, navigate to the consent screen
        if !notificationService.hasGivenConsent && notificationOptIn {
            countryForPermissionFlow = country
            showTravelAlertsPermission = true
        } else {
            subscribeToCountryAlerts(country, notificationOptIn)
        }
    }

    func proceedWithCountrySelection(_ country: Country, _ notificationEnabled: Bool) {
        subscribeToCountryAlerts(country, notificationEnabled)
    }

    private func subscribeToCountryAlerts(_ country: Country, _ notificationsEnabled: Bool) {
        viewState = .loading
        travelService.subscribeToCountry(
            slug: country.slug,
            notificationsEnabled: notificationsEnabled,
            completion: { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success:
                        self?.actions.dismissAction(true)
                    case .failure:
                        self?.actions.dismissAction(false)
                        self?.errorCallback?()
                    }
                }
            }
        )
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
                    self?.allCountries = countries
                    self?.updateFilteredSections()
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
                action: { [weak self] in
                    self?.selectedCountry = country
                }
            )
        }

        guard !rows.isEmpty else {
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

    private func updateFilteredSections() {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
        let filtered = trimmedSearch.isEmpty
        ? allCountries
        : allCountries.filter { item in
            let matchesCountry = item.name.localizedCaseInsensitiveContains(trimmedSearch)
            let matchesSynonym = item.synonyms.contains {
                $0.localizedCaseInsensitiveContains(trimmedSearch)
            }

            return matchesCountry || matchesSynonym
        }

        filteredSections = buildSections(from: filtered)
        viewState = filteredSections.isEmpty ? .empty : .loaded
    }

    func openFooterLink() {
        actions.openFooterLinkAction(footerLinkURL)
    }

    func dismiss(_ forceRefresh: Bool) {
        actions.dismissAction(forceRefresh)
    }

    func createPermissionViewModel() -> TravelAlertsPermissionViewModel? {
        guard let countryToProcess = self.countryForPermissionFlow else { return nil }
        return TravelAlertsPermissionViewModel(
            travelService: travelService,
            notificationService: notificationService,
            analyticsService: analyticsService,
            urlOpener: urlOpener,
            showImage: true,
            country: countryToProcess,
            dismissSheetAction: { [weak self] in
                self?.showTravelAlertsPermission = false
                self?.countryForPermissionFlow = nil
            },
            openExternalURLAction: self.actions.openExternalURLAction,
            dismissAfterSuccessAction: { [weak self] in
                self?.returnFromNotificationPermissions(forceRefresh: true)
            },
            dismissAfterErrorAction: { [weak self] in
                self?.returnFromNotificationPermissions(forceRefresh: false, didError: true)
            }
        )
    }

    private func returnFromNotificationPermissions(forceRefresh: Bool, didError: Bool = false) {
        self.showTravelAlertsPermission = false
        self.selectedCountry = nil
        self.countryForPermissionFlow = nil
        if didError {
            self.errorCallback?()
        }
        self.actions.dismissAction(forceRefresh)
    }
}
