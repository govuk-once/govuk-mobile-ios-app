import UIKit
import Foundation
import GovKit

class LocalAuthorityServiceCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let localAuthorityService: LocalAuthorityServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let dismissed: () -> Void

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         localAuthorityService: LocalAuthorityServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         dismissed: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.localAuthorityService = localAuthorityService
        self.coordinatorBuilder = coordinatorBuilder
        self.dismissed = dismissed
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.localAuthorityExplainerView(
            navigateToPostCodeEntryViewAction: { [weak self] in
                self?.navigateToPostcodeEntryView()
            },
            dismissAction: { [weak self] in
                self?.dismissModal()
            }
        )
        set(viewController, animated: true)
    }

    private func navigateToPostcodeEntryView() {
        let coord = coordinatorBuilder.editLocalAuthority(
            navigationController: root,
            dismissAction: dismissed
        )
        start(coord)
    }

    private func dismissModal() {
        root.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.finish()
            }
        )
    }

    override func finish() {
        super.finish()
        dismissed()
    }
}
