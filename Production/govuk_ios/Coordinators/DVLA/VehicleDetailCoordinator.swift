import Foundation
import UIKit
import GovKit

final class VehicleDetailCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let vehicle: CustomerSummary.Vehicle

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         vehicle: CustomerSummary.Vehicle) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.vehicle = vehicle
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.vehicleDetail(
            analyticsService: analyticsService,
            vehicle: vehicle
        )
        push(viewController)
    }
}
