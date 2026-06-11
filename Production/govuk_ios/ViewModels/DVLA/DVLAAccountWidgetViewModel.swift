import GovKit
import SwiftUI

class DVLAAccountWidgetViewModel: ObservableObject {
    enum ViewState {
        case loading
        case linked(actionCards: [ListCardViewModel], accountSummary: DVLAAccountSummaryViewModel)
        case unlinked(linkCard: ServiceAccountLinkCardViewModel)
        case error(AppErrorViewModel)
    }

    @Published private(set) var viewState: ViewState

    private let dateFormatter = DateFormatter.dvlaAccount
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let actions: Actions

    init(viewState: ViewState = .loading,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         dvlaService: DVLAServiceInterface,
         actions: Actions) {
        self.viewState = viewState
        self.analyticsService = analyticsService
        self.userService = userService
        self.dvlaService = dvlaService
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
            viewState = .error(dvlaAccountErrorViewModel)
        }
    }

    private func update(isAccountLinked: Bool) {
        if isAccountLinked {
            let vehiclesViewModel = VehiclesViewModel(
                analyticsService: analyticsService,
                dvlaService: dvlaService
            )
            let licenceViewModel = DrivingLicenceViewModel(
                analyticsService: analyticsService,
                dvlaService: dvlaService
            )
            let accountSummaryViewModel = DVLAAccountSummaryViewModel(
                vehiclesViewModel: vehiclesViewModel,
                licenceViewModel: licenceViewModel
            )
            viewState = .linked(
                actionCards: accountActionCards,
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

    private var dvlaAccountErrorViewModel: AppErrorViewModel {
        AppErrorViewModel.dvlaAccountErrorWithAction { [weak self] in
            Task { await self?.fetchLinkedAccounts() }
        }
    }

    private var accountActionCards: [ListCardViewModel] {
        let unlinkCard = ListCardViewModel(
            title: String.dvla.localized("dvlaAccountUnlinkCardTitle"),
            action: actions.unlinkAction
        )
        let viewDriverSummaryCard = ListCardViewModel(
            title: String.dvla.localized("dvlaViewDriverSummaryCardTitle"),
            action: actions.viewDriverSummaryAction
        )
        let viewCustomerSummaryCard = ListCardViewModel(
            title: String.dvla.localized("dvlaViewCustomerSummaryCardTitle"),
            action: actions.viewCustomerSummaryAction
        )
        let viewVehicleCard = ListCardViewModel(
            title: "View vehicle",
            action: actions.viewVehicleAction
        )
        let viewShareCodesCard = ListCardViewModel(
            title: "View check codes",
            action: actions.viewShareCodesAction
        )
        let createShareCodeCard = ListCardViewModel(
            title: "Create check code",
            action: actions.createShareCodeAction
        )
        return [
            unlinkCard,
            viewDriverSummaryCard,
            viewCustomerSummaryCard,
            viewVehicleCard,
            viewShareCodesCard,
            createShareCodeCard
        ]
    }

    private func trackLinkAccountNavigationEvent(title: String) {
        let event = AppEvent.linkServiceAccountNavigation(
            title: title
        )
        analyticsService.track(event: event)
    }
}

extension DVLAAccountWidgetViewModel {
    struct Actions {
        let linkAction: () -> Void
        let unlinkAction: () -> Void
        let viewDriverSummaryAction: () -> Void
        let viewCustomerSummaryAction: () -> Void
        let viewVehicleAction: () -> Void
        let viewShareCodesAction: () -> Void
        let createShareCodeAction: () -> Void
    }
}
