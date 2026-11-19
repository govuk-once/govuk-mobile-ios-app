import UIKit
import SwiftUI
import GovKit
import Foundation
import FactoryKit

@MainActor
protocol DWPCoordinatorBuilding {
    func benefitsContainer(
        navigationController: UINavigationController,
        viewControllerBuilder: ViewControllerBuilder,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface
    ) -> BaseCoordinator
}

@MainActor
extension CoordinatorBuilder: DWPCoordinatorBuilding {
    func benefitsContainer(
        navigationController: UINavigationController,
        viewControllerBuilder: ViewControllerBuilder,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface
    ) -> BaseCoordinator {
        BenefitsContainerCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: viewControllerBuilder,
            analyticsService: analyticsService,
            configService: configService
        )
    }
}
