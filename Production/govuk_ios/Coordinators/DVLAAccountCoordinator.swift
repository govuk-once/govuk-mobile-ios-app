import Foundation
import UIKit
import GovKit

final class DVLAAccountCoordinator: BaseCoordinator {
    private let dvlaService: DVLAServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         dvlaService: DVLAServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.dvlaService = dvlaService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.dvlaAccount(
            dvlaService: dvlaService
        )
        push(viewController)
    }
}
