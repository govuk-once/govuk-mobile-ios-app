//

import UIKit
import GovKit

class NotificationCentreCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let notificationCentreService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         notificationCentreService: NotificationCentreServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         coordinatorBuilder: CoordinatorBuilder) {
        self.viewControllerBuilder = viewControllerBuilder
        self.notificationCentreService = notificationCentreService
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.coordinatorBuilder = coordinatorBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = self
            .viewControllerBuilder
            .notificationCentre(showNotificationAction: { [weak self] notification in
                self?.showDetail(for: notification.id)
            }, notificationService: notificationCentreService,
                                analyticsService: analyticsService,
                                dvlaService: dvlaService)

        self.push(viewController, animated: true)
    }

    func showDetail(for notificationId: String) {
        let viewController = self.viewControllerBuilder
            .notificationCentreDetail(
                notificationId: notificationId,
                notificationService: notificationCentreService,
                analyticsService: analyticsService,
                showUrlAction: presentWebView(url:),
                onUnreadAction: {
                    self.root.popViewController(animated: true)
                },
                onDeleteAction: {
                    self.root.popViewController(animated: true)
                })
        self.push(viewController, animated: true)
    }

    private func presentWebView(url: URL) {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: true
        )
        start(coordinator, url: url)
    }
}
