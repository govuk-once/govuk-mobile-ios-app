import UIKit
import Foundation
import GovKit

final class SARSettingsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder
    private var userState: UserStateResult?

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
            analyticsService: analyticsService
        ) { [weak self] in
            self?.userService.fetchUserState { userState in
                self?.userState = userState
                print("userState = \(userState)")
            }
        }
        push(viewController)
    }
}
