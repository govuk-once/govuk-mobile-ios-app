import UIKit
import GovKit

final class ServiceAccountCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface,
         accountType: ServiceAccountType) {
        self.viewControllerBuilder = viewControllerBuilder
        self.userService = userService
        self.accountType = accountType
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {

    }

    private func linkAccount() {
        let linkId = "test-link-id"
        let viewController = viewControllerBuilder.serviceAccountLinking(
            userService: userService,
            accountType: accountType,
            linkId: linkId,
            completeAction: { [weak self] in
                self?.dismissModal()
                print("dvla account linked successfully")
            },
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func unlinkAccount() {
        let viewController = viewControllerBuilder.serviceAccountUnlinking(
            userService: userService,
            accountType: accountType,
            completeAction: { [weak self] in
                self?.dismissModal()
                print("dvla account unlinked successfully")
            },
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
