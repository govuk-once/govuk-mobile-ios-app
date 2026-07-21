import GovKit
import SwiftUI

class DVLAAccountWidgetViewModel: ObservableObject {
    enum ViewState {
        case loading
        case linked(accountSummary: DVLAAccountSummaryViewModel)
        case unlinked(linkCard: ServiceAccountLinkCardViewModel)
        case error(InlineActionErrorViewModel)
    }

    @Published private(set) var viewState: ViewState

    private let dateFormatter = DateFormatter.dvlaAccount
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let configService: AppConfigServiceInterface
    private let actions: Actions

    init(viewState: ViewState = .loading,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         dvlaService: DVLAServiceInterface,
         configService: AppConfigServiceInterface,
         actions: Actions) {
        self.viewState = viewState
        self.analyticsService = analyticsService
        self.userService = userService
        self.dvlaService = dvlaService
        self.configService = configService
        self.actions = actions
    }

    @MainActor
    func viewDidAppear() async {
        if let isAccountLinked = userService.linkedAccounts?.contains(.dvla) {
            update(isAccountLinked: isAccountLinked)
        } else {
            await fetchLinkedAccounts()
        }
    }

    @MainActor
    func fetchLinkedAccounts() async {
        viewState = .loading
        let result = await userService.fetchLinkedAccounts()
        switch result {
        case .success(let linkedAccounts):
            let isDVLAAccountLinked = linkedAccounts.contains(.dvla)
            update(isAccountLinked: isDVLAAccountLinked)
        case .failure:
            viewState = .error(linkedAccountsErrorViewModel)
        }
    }

    private func update(isAccountLinked: Bool) {
        if isAccountLinked {
            let vehiclesViewModel = VehiclesViewModel(
                analyticsService: analyticsService,
                dvlaService: dvlaService,
                configService: configService,
                detailAction: actions.vehicleDetailAction,
                openURLAction: actions.openURLAction
            )
            let licenceViewModel = DrivingLicenceViewModel(
                analyticsService: analyticsService,
                dvlaService: dvlaService,
                configService: configService,
                openURLAction: actions.openURLAction
            )
            let accountSummaryViewModel = DVLAAccountSummaryViewModel(
                vehiclesViewModel: vehiclesViewModel,
                licenceViewModel: licenceViewModel
            )
            viewState = .linked(
                accountSummary: accountSummaryViewModel
            )
        } else {
            viewState = .unlinked(linkCard: linkCardViewModel)
        }
    }

    private var linkCardViewModel: ServiceAccountLinkCardViewModel {
        let linkCardTitle = String.dvla.localized("dvlaAccountLinkCardTitle")
        return ServiceAccountLinkCardViewModel(
            title: linkCardTitle,
            subtitle: String.dvla.localized("dvlaAccountLinkCardSubtitle"),
            action: { [weak self] in
                self?.trackLinkAccountNavigationEvent(title: linkCardTitle)
                self?.actions.linkAction()
            }
        )
    }

    private var linkedAccountsErrorViewModel: InlineActionErrorViewModel {
        let url = configService.dvlaUrls?.account ?? Constants.API.defaultDvlaAccountUrl
        let buttonTitle = String(localized: .DVLA.accountWidgetErrorButtonTitle)
        let markdownBody = String(
            localized: .DVLA.accountWidgetErrorBody(
                buttonTitle: buttonTitle,
                url: url.absoluteString
            )
        )
        return InlineActionErrorViewModel(
            title: String(localized: .DVLA.accountWidgetErrorTitle),
            markdownBody: markdownBody,
            openURLAction: { [weak self] url in
                self?.trackOpenURLAction(url: url, buttonTitle: buttonTitle)
                self?.actions.openURLAction(url)
            }
        )
    }

    private func trackLinkAccountNavigationEvent(title: String) {
        let event = AppEvent.linkServiceAccountNavigation(
            title: title
        )
        analyticsService.track(event: event)
    }

    private func trackOpenURLAction(url: URL, buttonTitle: String) {
        let event = AppEvent.buttonNavigation(
            text: buttonTitle,
            external: true,
            url: url.absoluteString,
            section: "Driving"
        )
        analyticsService.track(event: event)
    }
}

extension DVLAAccountWidgetViewModel {
    struct Actions {
        let linkAction: () -> Void
        let vehicleDetailAction: (Int) -> Void
        let openURLAction: (URL) -> Void
    }
}
