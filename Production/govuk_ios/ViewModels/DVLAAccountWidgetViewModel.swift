import GovKit
import SwiftUI

class DVLAAccountWidgetViewModel: ObservableObject {
    @Published private(set) var actionCards = [ListCardViewModel]()
    @Published private(set) var errorViewModel: AppErrorViewModel?
    @Published private(set) var linkCardViewModel: ServiceAccountLinkCardViewModel?
    @Published private(set) var isLoading: Bool = false
    private let dateFormatter = DateFormatter.dvlaAccount

    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let actions: Actions

    init(analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         dvlaService: DVLAServiceInterface,
         actions: Actions) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.dvlaService = dvlaService
        self.actions = actions
    }

    @MainActor
    func viewDidAppear() async {
        if let isAccountLinked = userService.isDvlaAccountLinked {
            update(isAccountLinked: isAccountLinked)
        } else {
            await fetchLinkStatus()
        }
    }

    @MainActor
    func fetchLinkStatus() async {
        isLoading = true
        let result = await userService.fetchAccountLinkStatus(accountType: .dvla)
        isLoading = false
        switch result {
        case .success(let linkStatus):
            update(isAccountLinked: linkStatus.linked)
        case .failure:
            errorViewModel = AppErrorViewModel.dvlaAccountErrorWithAction {
                Task { await self.fetchLinkStatus() }
            }
        }
    }

    private func update(isAccountLinked: Bool) {
        if isAccountLinked {
            linkCardViewModel = nil
            createAccountSection()
        } else {
            actionCards = []
            let linkCardTitle = String.dvla.localized("dvlaAccountLinkCardTitle")
            linkCardViewModel = ServiceAccountLinkCardViewModel(
                title: linkCardTitle,
                subtitle: String.dvla.localized("dvlaAccountLinkCardSubtitle"),
                action: { [weak self] in
                    self?.trackLinkAccountNavigationEvent(title: linkCardTitle)
                    self?.actions.linkAction()
                }
            )
        }
    }

    private func createAccountSection() {
        let unlinkCard = ListCardViewModel(
            title: String.dvla.localized("dvlaAccountUnlinkCardTitle"),
            action: actions.unlinkAction
        )
        let viewLicenceCard = ListCardViewModel(
            title: String.dvla.localized("dvlaViewDrivingLicenceCardTitle"),
            action: actions.viewLicenceAction
        )
        let viewDriverSummaryCard = ListCardViewModel(
            title: String.dvla.localized("dvlaViewDriverSummaryCardTitle"),
            action: actions.viewDriverSummaryAction
        )
        let viewCustomerSummaryCard = ListCardViewModel(
            title: String.dvla.localized("dvlaViewCustomerSummaryCardTitle"),
            action: actions.viewCustomerSummaryAction
        )
        actionCards = [
            unlinkCard,
            viewLicenceCard,
            viewDriverSummaryCard,
            viewCustomerSummaryCard
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
        let viewLicenceAction: () -> Void
        let viewDriverSummaryAction: () -> Void
        let viewCustomerSummaryAction: () -> Void
    }
}
