import UIKit
import Foundation
import GovKit

class YourAccountsSettingsCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let coordinatorBuilder: CoordinatorBuilder
    private let unlinkErrorAction: () -> Void
    private let userService: UserServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         analyticsService: AnalyticsServiceInterface,
         unlinkErrorAction: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.analyticsService = analyticsService
        self.unlinkErrorAction = unlinkErrorAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.yourAccountsSettings(
            userService: userService,
            analyticsService: analyticsService,
            unlinkErrorAction: { [weak self] in
                self?.pushUnlinkAccountsErrorView()
            }
        )
        push(viewController, animated: true)
    }

    private func pushUnlinkAccountsErrorView() {
        let viewController = viewControllerBuilder.unlinkAccountsErrorView(
            unlinkErrorAction: { [weak self] in
                self?.start()
            }
        )
        viewController.hidesBottomBarWhenPushed = true
        push(viewController, animated: true)
    }
}
