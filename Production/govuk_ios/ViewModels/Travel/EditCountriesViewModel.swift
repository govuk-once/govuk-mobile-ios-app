import Foundation
import UIKit
import GovKit
import GovKitUI

// swiftlint:disable:next type_body_length
class EditCountriesViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded
        case error
    }

    enum NotificationsRationaleFlowOutcome {
        case none
        case success
        case error
        case declined
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
    @Published var displayToggleError: Bool = false
    @Published var displayUnfollowError: Bool = false
    @Published var isShowingFollowError = false
    @Published var showNotificationsRationale = false

    private let travelService: TravelServiceInterface
    private let notificationService: NotificationServiceInterface
    private let urlOpener: URLOpener
    let analyticsService: AnalyticsServiceInterface
    private let feedbackURL: URL
    private let openCountryListFooterAction: () -> Void
    private var allCountries: [Country] = []
    private var follewedCountries: Set<String> = []
    private var notificationStateCache: [String: Bool] = [:]
    private var rationaleFlowSlug: String?
    private var rationaleFlowOutcome: NotificationsRationaleFlowOutcome = .none
    private var rationaleViewModel: NotificationsRationaleViewModel?

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
        notificationService: NotificationServiceInterface,
        urlOpener: URLOpener,
        feedbackURL: URL,
        openCountryListFooterAction: @escaping () -> Void
    ) {
        self.travelService = travelService
        self.analyticsService = analyticsService
        self.notificationService = notificationService
        self.urlOpener = urlOpener
        self.feedbackURL = feedbackURL
        self.openCountryListFooterAction = openCountryListFooterAction
    }

    @MainActor
    lazy var countryListViewModel: CountryListViewModel = {
        let actions = CountryListViewModel.Actions(
            dismissAction: { [weak self] forceRefresh in
                Task {
                    self?.didDismissList(forceRefresh: forceRefresh)
                }
            },
            openFooterLinkAction: { [weak self] in
                self?.openCountryListFooterAction()
            },
            openExternalURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            }
        )

        return CountryListViewModel(
            travelService: travelService,
            analyticsService: analyticsService,
            notificationService: notificationService,
            urlOpener: urlOpener,
            actions: actions,
            errorCallback: { [weak self] in
                self?.isShowingFollowError = true
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
    func requestToggle(slug: String, enabled: Bool) async {
        guard enabled else {
            await toggleNotifications(slug: slug, enabled: false)
            return
        }
        if await notificationService.needsTravelAlertsPermissionFlow {
            selectedCountryNotificationEnabled = true
            rationaleFlowSlug = slug
            rationaleFlowOutcome = .declined
            showNotificationsRationale = true
        } else {
            await toggleNotifications(slug: slug, enabled: true)
        }
    }

    @MainActor
    func toggleNotifications(slug: String, enabled: Bool) async {
        isToggleLoading = true
        selectedCountryNotificationEnabled = enabled
        notificationStateCache[slug] = enabled
        travelService.toggleNotifications(slug: slug, enabled: enabled) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.isToggleLoading = false
                case .failure:
                    let previousValue = !(enabled)
                    self?.selectedCountryNotificationEnabled = previousValue
                    self?.notificationStateCache[slug] = previousValue
                    self?.isToggleLoading = false
                    self?.displayToggleError = true
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
                    self?.displayUnfollowError = true
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
        displayToggleError = false
    }

    func clearUnfollowError() {
        isShowingCountryDetails = false
        displayUnfollowError = false
    }

    func clearFollowError() {
        isShowingFollowError = false
    }

    func createNotificationsRationaleViewModel() -> NotificationsRationaleViewModel? {
        guard let slug = rationaleFlowSlug else { return nil }
        return NotificationsRationaleViewModel(
            notificationService: notificationService,
            analyticsService: analyticsService,
            urlOpener: urlOpener,
            showImage: true,
            saveAction: { [travelService] enabled, completion in
                travelService.toggleNotifications(
                    slug: slug,
                    enabled: enabled,
                    completion: completion
                )
            },
            declineBehaviour: .report({ [weak self] in
                self?.finishRationaleFlow(.declined)
            }),
            dismissSheetAction: { [weak self] in
                self?.finishRationaleFlow(.declined)
            },
            openExternalURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            dismissAfterSuccessAction: { [weak self] in
                self?.finishRationaleFlow(.success)
            },
            dismissAfterErrorAction: { [weak self] in
                self?.finishRationaleFlow(.error)
            }
        )
    }

    private func finishRationaleFlow(_ outcome: NotificationsRationaleFlowOutcome) {
        rationaleFlowOutcome = outcome
        showNotificationsRationale = false
    }

    @MainActor
    func rationaleFlowDidDismiss() {
        guard let slug = rationaleFlowSlug else { return }
        switch rationaleFlowOutcome {
        case .success:
            notificationStateCache[slug] = true
            selectedCountryNotificationEnabled = true
        case .error:
            selectedCountryNotificationEnabled = false
            displayToggleError = true
        case .declined, .none:
            selectedCountryNotificationEnabled = false
        }
        rationaleFlowSlug = nil
        rationaleFlowOutcome = .none
        rationaleViewModel = nil
    }

    private func showCountryDetails(country: Country, subgroup: String) {
        selectedCountry = SelectedCountry(country: country, subgroup: subgroup)
        if let cachedState = notificationStateCache[country.slug] {
            selectedCountryNotificationEnabled = cachedState
        } else {
            selectedCountryNotificationEnabled = subgroup.lowercased() == "instant"
        }
        isShowingCountryDetails = true
    }
}
