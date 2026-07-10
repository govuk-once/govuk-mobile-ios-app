import Foundation
import UIKit
import GovKit

final class VehicleDetailCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let vehicleId: Int

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         vehicleId: Int) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.vehicleId = vehicleId
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.vehicleDetail(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            vehicleId: vehicleId
        )
        push(viewController)
    }
}
