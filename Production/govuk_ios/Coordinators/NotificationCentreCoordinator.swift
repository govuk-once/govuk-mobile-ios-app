//

import UIKit
import GovKit

class NotificationCentreCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let notificationCentreService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         notificationCentreService: NotificationCentreServiceInterface,
         analyticsService: AnalyticsServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.notificationCentreService = notificationCentreService
        self.analyticsService = analyticsService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = self.viewControllerBuilder.notificationCentre(showNotificationAction: { [weak self] notification in
            self?.showDetail(notification: notification)
        }, notificationService: notificationCentreService, analyticsService: analyticsService)
        self.push(viewController, animated: true)
    }
    
    func showDetail(notification: Notification) {
        let viewController = self.viewControllerBuilder.notificationCentreDetail(notification: notification)
        self.push(viewController, animated: true)
    }
}
