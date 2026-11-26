import Combine
import Foundation
import GovKitUI
import GovKit

class CountryListViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case empty
        case error(AppErrorViewModel)
    }

    enum CountryListAnalyticsKeys {
        static let section = "Travel Abroad Notifications"
        static let searchSection = "country_search"
        static let closeText = "Close"
    }

    struct Actions {
        let dismissAction: (Bool) -> Void
        let openFooterLinkAction: () -> Void
        let openExternalURLAction: (URL) -> Void
    }

    /// How long the search text must stay unchanged before a search with no results is tracked.
    static let noResultsSearchDebounceMilliseconds = 500

    @Published private(set) var viewState: ViewState = .loading
    @Published var searchText = "" {
        didSet {
            updateFilteredSections()
        }
    }
    @Published private(set) var filteredSections = [GroupedListSection]()
    @Published var selectedCountry: Country?
    @Published var showNotificationsRationale = false
    private var countryForPermissionFlow: Country?

    private var allCountries: [Country] = []
    private let travelService: TravelServiceInterface
    let analyticsService: AnalyticsServiceInterface
    private let notificationService: NotificationServiceInterface
    private let urlOpener: URLOpener
    private let actions: Actions
    private let footerLinkURLString: String?
    let errorCallback: (() -> Void)?
    private var noResultsSearchCancellable: AnyCancellable?
    // Set when the app closes the sheet itself, so the sheet's onDismiss
    // doesn't also count it as the user closing it.
    private var isDismissalHandled = false

    var hasNotificationConsent: Bool {
        notificationService.hasGivenConsent
    }

    init<S: Scheduler>(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        notificationService: NotificationServiceInterface,
        urlOpener: URLOpener,
        actions: Actions,
        footerLinkURLString: String? = nil,
        errorCallback: (() -> Void)? = nil,
        searchDebounceScheduler: S
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.notificationService = notificationService
        self.urlOpener = urlOpener
        self.actions = actions
        self.footerLinkURLString = footerLinkURLString
        self.errorCallback = errorCallback
        noResultsSearchCancellable = trackSearchesWithNoResults(
            scheduler: searchDebounceScheduler
        )
    }

    convenience init(
        travelService: TravelServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        notificationService: NotificationServiceInterface,
        urlOpener: URLOpener,
        actions: Actions,
        footerLinkURLString: String? = nil,
        errorCallback: (() -> Void)? = nil
    ) {
        self.init(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            urlOpener: urlOpener,
            actions: actions,
            footerLinkURLString: footerLinkURLString,
            errorCallback: errorCallback,
            searchDebounceScheduler: DispatchQueue.main
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
}

// MARK: - Country list loading
extension CountryListViewModel {
    @MainActor
    private func fetchCountryList() async {
        viewState = .loading

        let result = await withCheckedContinuation { continuation in
            travelService.getCountries(forceRefresh: false) { result in
                continuation.resume(returning: result)
            }
        }

        processCountriesResult(result)
    }

    @MainActor
    private func processCountriesResult(_ result: Result<[Country], TravelError>) {
        switch result {
        case .success(let countries):
            allCountries = countries
            updateFilteredSections()
        case .failure(let error):
            handleCountryFetchError(error)
        }
    }

    @MainActor
    private func handleCountryFetchError(_ error: TravelError) {
        let retryAction: () -> Void = { [weak self] in
            Task { await self?.retryFetchCountryList() }
        }

        let errorViewModel = switch error {
        case .networkUnavailable:
            AppErrorViewModel.networkUnavailable(action: retryAction)
        default:
            AppErrorViewModel.travelGenericError(retryAction: retryAction)
        }

        viewState = .error(errorViewModel)
    }
}

// MARK: - Country selection
extension CountryListViewModel {
    func onGetNotificationAlertTap(_ country: Country, text: String) {
        analyticsService.track(
            event: AppEvent.widgetNavigation(
                text: text,
                external: false,
                params: ["section": CountryListAnalyticsKeys.section]
            )
        )
        Task {
            await handleCountrySelection(country, notificationOptIn: true)
        }
    }

    func onNotNowAlertTap(_ country: Country, text: String) {
        analyticsService.track(
            event: AppEvent.widgetNavigation(
                text: text,
                external: false,
                params: ["section": CountryListAnalyticsKeys.section]
            )
        )
        Task {
            await handleCountrySelection(country, notificationOptIn: false)
        }
    }

    func onCancelAlertTap(text: String) {
        analyticsService.track(
            event: AppEvent.widgetNavigation(
                text: text,
                external: false,
                params: ["section": CountryListAnalyticsKeys.section]
            )
        )
        selectedCountry = nil
    }

    func onSearchSubmitted() {
        guard !searchText.isEmpty else { return }
        trackSearchInput(text: searchText)
    }

    func onCountryTap(_ country: Country) {
        trackToggleFunction(countryName: country.name)
        if !searchText.isEmpty {
            trackSearchInput(text: searchText)
        }
        selectedCountry = country
    }

    @MainActor
    private func handleCountrySelection(_ country: Country, notificationOptIn: Bool) async {
        if notificationOptIn {
            let needsPermissionFlow = await notificationService.needsTravelAlertsPermissionFlow
            if needsPermissionFlow {
                selectedCountry = nil
                countryForPermissionFlow = country
                showNotificationsRationale = true
            } else {
                subscribeToCountryAlerts(country, notificationOptIn)
            }
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
                    self?.processSubscriptionResult(result)
                }
            }
        )
    }

    @MainActor
    private func processSubscriptionResult(_ result: Result<Void, TravelError>) {
        switch result {
        case .success:
            dismiss(true)
        case .failure:
            dismiss(false)
            errorCallback?()
        }
    }
}

// MARK: - Country list filtering
extension CountryListViewModel {
    private func buildSections(from countries: [Country]) -> [GroupedListSection] {
        let sortedCountries = countries.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        let rows = sortedCountries.map { country in
            SelectableRow(
                id: country.slug,
                title: country.name,
                action: { [weak self] in
                    self?.onCountryTap(country)
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

    func updateFilteredSections() {
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

    func openFooterLink(text: String) {
        let buttonTapEvent = AppEvent.buttonNavigation(
            text: text,
            external: true,
            url: footerLinkURLString,
            section: CountryListAnalyticsKeys.section
        )
        analyticsService.track(event: buttonTapEvent)

        actions.openFooterLinkAction()
    }

    func dismiss(_ forceRefresh: Bool) {
        isDismissalHandled = true
        actions.dismissAction(forceRefresh)
    }
}

// MARK: - Sheet dismissal
extension CountryListViewModel {
    func closeButtonTapped() {
        trackClose()
        selectedCountry = nil
        dismiss(false)
    }

    func sheetDidAppear() {
        isDismissalHandled = false
    }

    /// Call from the presenting sheet's `onDismiss`. Any dismissal the app didn't
    /// trigger itself (e.g. swipe down) is the user closing the sheet.
    func sheetDidDismiss() {
        if !isDismissalHandled {
            trackClose()
        }
        isDismissalHandled = false
    }
}

// MARK: - Notifications Rationale Flow
extension CountryListViewModel {
    func createNotificationsRationaleViewModel() -> NotificationsRationaleViewModel? {
        guard let countryToProcess = self.countryForPermissionFlow else { return nil }
        return NotificationsRationaleViewModel(
            notificationService: notificationService,
            analyticsService: analyticsService,
            urlOpener: urlOpener,
            showImage: true,
            saveAction: { [travelService] enabled, completion in
                travelService.subscribeToCountry(
                    slug: countryToProcess.slug,
                    notificationsEnabled: enabled,
                    completion: completion
                )
            },
            declineBehaviour: .saveDisabled,
            dismissSheetAction: { [weak self] in
                self?.showNotificationsRationale = false
                self?.countryForPermissionFlow = nil
            },
            openExternalURLAction: self.actions.openExternalURLAction,
            dismissAfterSuccessAction: { [weak self] in
                self?.returnFromNotificationPermissions(forceRefresh: true)
            },
            dismissAfterErrorAction: { [weak self] in
                self?.returnFromNotificationPermissions(forceRefresh: false, didError: true)
            },
            origin: .FOLLOW
        )
    }

    private func returnFromNotificationPermissions(forceRefresh: Bool, didError: Bool = false) {
        self.showNotificationsRationale = false
        self.selectedCountry = nil
        self.countryForPermissionFlow = nil
        if didError {
            self.errorCallback?()
        }
        self.dismiss(forceRefresh)
    }

    func resetNotificationsRationaleFlow() {
        showNotificationsRationale = false
        countryForPermissionFlow = nil
    }
}
