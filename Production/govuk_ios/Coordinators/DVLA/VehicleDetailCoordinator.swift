import Foundation
import UIKit
import GovKit

final class VehicleDetailCoordinator: BaseCoordinator {
    private let urlOpener: URLOpener
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    private let vehicle: CustomerSummary.Vehicle

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         urlOpener: URLOpener,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         vehicle: CustomerSummary.Vehicle) {
        self.viewControllerBuilder = viewControllerBuilder
        self.urlOpener = urlOpener
        self.analyticsService = analyticsService
        self.configService = configService
        self.vehicle = vehicle
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.vehicleDetail(
            analyticsService: analyticsService,
            configService: configService,
            vehicle: vehicle,
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            }
        )
        push(viewController)
    }
}
