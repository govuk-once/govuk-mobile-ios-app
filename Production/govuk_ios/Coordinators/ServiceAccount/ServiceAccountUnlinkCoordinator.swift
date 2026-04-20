import UIKit
import GovKit

final class ServiceAccountUnlinkCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType
    private let completion: () -> Void

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface,
         accountType: ServiceAccountType,
         completion: @escaping () -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.userService = userService
        self.accountType = accountType
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start() {
        unlinkAccount()
    }

    private func unlinkAccount() {
        let viewController = viewControllerBuilder.serviceAccountUnlinking(
            userService: userService,
            accountType: accountType,
            completeAction: { [weak self] in
                self?.dismissModal()
                print("dvla account unlinked successfully")
                self?.completion()
            },
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
