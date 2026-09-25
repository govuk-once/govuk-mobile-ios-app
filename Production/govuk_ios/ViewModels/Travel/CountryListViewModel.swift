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
    let dismissAction: (Bool) -> Void
    let errorCallback: () -> Void
    let openPrivacyPolicyAction: () -> Void

    var hasNotificationConsent: Bool {
        notificationService.hasGivenConsent
    }

    init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        notificationService: NotificationServiceInterface,
        dismissAction: @escaping (Bool) -> Void,
        errorCallback: @escaping () -> Void = {},
        openPrivacyPolicyAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.notificationService = notificationService
        self.dismissAction = dismissAction
        self.errorCallback = errorCallback
        self.openPrivacyPolicyAction = openPrivacyPolicyAction
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
                        self?.dismissAction(true)
                    case .failure:
                        self?.dismissAction(false)
                        self?.errorCallback()
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

    func createPermissionViewModel() -> TravelAlertsPermissionViewModel {
        let countryToProcess = self.countryForPermissionFlow
        return TravelAlertsPermissionViewModel(
            analyticsService: analyticsService,
            showImage: true,
            title: String(localized: .Travel.travelAlertPermissionTitle),
            body: String(localized: .Travel.travelAlertPermissionDescription),
            primaryButtonTitle: String(
                localized: .Travel.travelAlertPermissionPrimaryButton
            ),
            secondaryButtonTitle: String(
                localized: .Travel.travelAlertPermissionSecondaryButton
            ),
            dismissSheetAction: { [weak self] in
                self?.showTravelAlertsPermission = false
                self?.countryForPermissionFlow = nil
            },
            allowNotificationsAction: { [weak self, country = countryToProcess] in
                if let country = country {
                    self?.proceedWithCountrySelection(country, true)
                    self?.showTravelAlertsPermission = false
                    self?.selectedCountry = nil
                    self?.countryForPermissionFlow = nil
                }
            },
            notNowAction: { [weak self, country = countryToProcess] in
                if let country = country {
                    self?.proceedWithCountrySelection(country, false)
                    self?.showTravelAlertsPermission = false
                    self?.selectedCountry = nil
                    self?.countryForPermissionFlow = nil
                }
            },
            viewPrivacyAction: { [weak self] in
                self?.openPrivacyPolicyAction()
            }
        )
    }
}
