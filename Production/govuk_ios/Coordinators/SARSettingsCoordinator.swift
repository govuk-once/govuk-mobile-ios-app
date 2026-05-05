import UIKit
import Foundation
import GovKit

final class SARSettingsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.viewControllerBuilder = viewControllerBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.sarSettings(
            analyticsService: analyticsService,
            userService: userService
        ) {
            print("action complete!!!!")
        }
        push(viewController)
    }
}
