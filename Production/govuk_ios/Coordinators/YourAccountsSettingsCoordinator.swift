import UIKit
import Foundation
import GovKit

class YourAccountsSettingsCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let dismissAction: () -> Void
    private let userService: UserServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         dismissAction: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.dismissAction = dismissAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.yourAccountSettings(
            analyticsService: analyticsService,
            userService: userService,
            dismissAction: { [weak self] in
                self?.dismissAction()
            }
        )
        push(viewController, animated: true)
    }
}
