import UIKit
import SwiftUI
import Foundation
import FactoryKit

@MainActor
protocol DVLACoordinatorBuilding {
    func vehicleCheck(navigationController: UINavigationController) -> BaseCoordinator
    func vehicleDetail(navigationController: UINavigationController,
                       vehicleId: Int) -> BaseCoordinator
    func licenceCategories(
        navigationController: UINavigationController,
        entitlements: [Entitlement]
    ) -> BaseCoordinator

    // KK Stuff
    func categoriesList(navigationController: UINavigationController) -> BaseCoordinator
    func categoriesListWithData(
        navigationController: UINavigationController
    ) -> BaseCoordinator
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

    func licenceCategories(
        navigationController: UINavigationController,
        entitlements: [Entitlement]
    ) -> BaseCoordinator {
        LicenceCategoriesCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            entitlements: entitlements
        )
    }

    // KK Stuff

    func categoriesList(navigationController: UINavigationController) -> BaseCoordinator {
        return CategoriesListCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            dvlaService: container.dvlaService.resolve(),
            configService: container.appConfigService.resolve(),
            userService: container.userService.resolve(),
            urlOpener: UIApplication.shared,
            notificationCenter: .default,
        )
    }

    func categoriesListWithData(
        navigationController: UINavigationController
    ) -> BaseCoordinator {
        let entitlementsInfo = EntitlementInfo(
            displayName: "dummy",
            entitlements: ["AM2": ("palm-tree", "r&d")],
            byGroup: ["r&d": ("AM2", "palm-tree")]
        )

        return CategoriesListWithDataCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            dvlaService: container.dvlaService.resolve(),
            configService: container.appConfigService.resolve(),
            userService: container.userService.resolve(),
            urlOpener: UIApplication.shared,
            notificationCenter: .default,
            specificData: entitlementsInfo
        )
    }
}
