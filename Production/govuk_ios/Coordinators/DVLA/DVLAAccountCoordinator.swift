import UIKit
import GovKit

final class DVLAAccountCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let dvlaService: DVLAServiceInterface

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         dvlaService: DVLAServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.dvlaService = dvlaService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let linkId = "test-link-id"
        let viewController = viewControllerBuilder.dvlaAccountLinking(
            dvlaService: dvlaService,
            linkId: linkId,
            completeAction: { [weak self] in
                self?.dismissModal()
                print("dvla account linked successfully")
            },
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
