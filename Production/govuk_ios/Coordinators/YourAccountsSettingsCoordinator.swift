import UIKit
import Foundation
import GovKit

class YourAccountsSettingsCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let coordinatorBuilder: CoordinatorBuilder
    private let userService: UserServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         analyticsService: AnalyticsServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.yourAccountsSettings(
            userService: userService,
            analyticsService: analyticsService
        )
        push(viewController, animated: true)
    }
}
