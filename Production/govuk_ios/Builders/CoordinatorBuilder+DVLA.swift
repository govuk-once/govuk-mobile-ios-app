import UIKit
import SwiftUI
import Foundation
import FactoryKit

@MainActor
protocol DVLACoordinatorBuilding {
    func vehicleCheck(navigationController: UINavigationController) -> BaseCoordinator
    func vehicleDetail(navigationController: UINavigationController,
                       vehicleId: Int) -> BaseCoordinator
    func licenceCategoriesCoordinator(entitlements: [Entitlement]) -> BaseCoordinator
}

@MainActor
extension CoordinatorBuilder: DVLACoordinatorBuilding {
    func vehicleCheck(
        navigationController: UINavigationController
    ) -> BaseCoordinator {
        VehicleCheckCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            configService: container.appConfigService.resolve(),
            urlOpener: UIApplication.shared,
            dvlaService: container.dvlaService.resolve()
        )
    }

    func vehicleDetail(
        navigationController: UINavigationController,
        vehicleId: Int
    ) -> BaseCoordinator {
        VehicleDetailCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            dvlaService: container.dvlaService.resolve(),
            configService: container.appConfigService.resolve(),
            userService: container.userService.resolve(),
            urlOpener: UIApplication.shared,
            notificationCenter: .default,
            vehicleId: vehicleId
        )
    }

    func licenceCategoriesCoordinator(
        entitlements: [Entitlement]
    ) -> BaseCoordinator {
        LicenceCategoriesCoordinator(
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            entitlements: entitlements
        )
    }
}
