import Foundation
import UIKit
import GovKit

class MailboxCoordinator: TabItemCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let mailboxService: MailboxServiceInterface

    var isEnabled: Bool {
        mailboxService.isEnabled
    }

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         mailboxService: MailboxServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.mailboxService = mailboxService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.mailboxList(
            mailboxService: mailboxService,
            analyticsService: analyticsService,
            messageSelectedAction: showMessageDetail
        )
        set([viewController], animated: false)
    }

    func route(for url: URL) -> ResolvedDeeplinkRoute? {
        nil
    }

    func didSelectTab(_ selectedTabIndex: Int,
                      previousTabIndex: Int) {
        if selectedTabIndex == previousTabIndex {
            root.popToRootViewController(animated: true)
        }
    }

    private func showMessageDetail(_ message: MailboxMessage) {
        let viewController = viewControllerBuilder.mailboxDetail(
            message: message,
            analyticsService: analyticsService,
            actionHandler: handleAction,
            deleteHandler: handleDelete,
            markUnopenedHandler: handleMarkUnopened
        )
        push(viewController)
    }

    private func handleAction(_ action: MessageAction) {
        switch action {
        case .applyInApp(_, let destination):
            navigateToDestination(destination)
        case .openURL(_, let url):
            UIApplication.shared.open(url)
        }
    }

    private func handleDelete(_ message: MailboxMessage) {
        mailboxService.deleteMessage(messageId: message.id) { _ in }
        root.popViewController(animated: true)
    }

    private func handleMarkUnopened(_ message: MailboxMessage) {
        mailboxService.markAsUnopened(messageId: message.id) { _ in }
        root.popViewController(animated: true)
    }

    private func navigateToDestination(
        _ destination: MessageDestination
    ) {
        switch destination {
        case .dvlaRenewLicence:
            if let url = URL(
                string: "https://www.gov.uk/renew-driving-licence"
            ) {
                UIApplication.shared.open(url)
            }
        case .dvlaVehicleTax:
            if let url = URL(
                string: "https://www.gov.uk/vehicle-tax"
            ) {
                UIApplication.shared.open(url)
            }
        }
    }
}
