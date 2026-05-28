import UIKit
import Foundation
import GovKit

class YourAccountsSettingsCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let coordinatorBuilder: CoordinatorBuilder
    private let dismissAction: () -> Void
    private let userService: UserServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         dismissAction: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.dismissAction = dismissAction
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.yourAccountsSettings(
            userService: userService,
            dismissAction: { [weak self] in
                self?.dismissAction()
            }
        )
        push(viewController, animated: true)
    }
}
