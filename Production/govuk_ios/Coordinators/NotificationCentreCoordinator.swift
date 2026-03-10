//

import UIKit
import GovKit

class NotificationCentreCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let notificationCentreService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         notificationCentreService: NotificationCentreServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         coordinatorBuilder: CoordinatorBuilder) {
        self.viewControllerBuilder = viewControllerBuilder
        self.notificationCentreService = notificationCentreService
        self.analyticsService = analyticsService
        self.coordinatorBuilder = coordinatorBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = self.viewControllerBuilder.notificationCentre(showNotificationAction: { [weak self] notification in
            self?.showDetail(notification: notification)
        }, notificationService: notificationCentreService, analyticsService: analyticsService)
        viewController.navigationItem.backButtonTitle = "Notification Centre" // TODO Localise
        self.push(viewController, animated: true)
    }
    
    func showDetail(notification: Notification) {
        let viewController = self.viewControllerBuilder.notificationCentreDetail(notification: notification, notificationService: notificationCentreService, analyticsService: analyticsService, showUrlAction: presentWebView(url:))
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
