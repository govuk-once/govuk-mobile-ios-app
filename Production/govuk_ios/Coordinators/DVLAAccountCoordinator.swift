import Foundation
import UIKit
import GovKit

enum DVLAAccountViewType {
    case drivingLicence
    case driverSummary
}

final class DVLAAccountCoordinator: BaseCoordinator {
    private let dvlaService: DVLAServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder
    private let viewType: DVLAAccountViewType

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         dvlaService: DVLAServiceInterface,
         viewType: DVLAAccountViewType) {
        self.viewType = viewType
        self.viewControllerBuilder = viewControllerBuilder
        self.dvlaService = dvlaService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.dvlaAccount(
            dvlaService: dvlaService,
            viewType: viewType
        )
        push(viewController)
    }
}
