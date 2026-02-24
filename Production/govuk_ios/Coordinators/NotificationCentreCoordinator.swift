//

import UIKit

class NotificationCentreCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let notificationCentreService: NotificationCentreServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         notificationCentreService: NotificationCentreServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.notificationCentreService = notificationCentreService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = self.viewControllerBuilder.notificationCentre(showNotificationAction: { [weak self] notification in
            self?.showDetail(notification: notification)
        }, notificationService: notificationCentreService)
        self.push(viewController, animated: true)
    }
    
    func showDetail(notification: Notification) {
        let viewController = self.viewControllerBuilder.notificationCentreDetail(notification: notification)
        self.push(viewController, animated: true)
    }
}
