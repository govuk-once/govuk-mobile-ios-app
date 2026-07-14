import Foundation
import UIKit
import GovKit

final class VehicleDetailCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let dvlaService: DVLAServiceInterface
    private let configService: AppConfigServiceInterface
    private let urlOpener: URLOpener
    private let vehicleId: Int

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         dvlaService: DVLAServiceInterface,
         configService: AppConfigServiceInterface,
         urlOpener: URLOpener,
         vehicleId: Int) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.dvlaService = dvlaService
        self.configService = configService
        self.urlOpener = urlOpener
        self.vehicleId = vehicleId
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.vehicleDetail(
            analyticsService: analyticsService,
            dvlaService: dvlaService,
            configService: configService,
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            vehicleId: vehicleId
        )
        push(viewController)
    }
}
