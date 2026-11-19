import UIKit
import SwiftUI
import GovKit
import Foundation
import FactoryKit

@MainActor
protocol BenefitsCoordinatorBuilding {
    func benefitsContainer(
        navigationController: UINavigationController,
        viewControllerBuilder: BenefitsViewControllerBuilding,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface
    ) -> BaseCoordinator
}

@MainActor
extension CoordinatorBuilder: BenefitsCoordinatorBuilding {
    func benefitsContainer(
        navigationController: UINavigationController,
        viewControllerBuilder: BenefitsViewControllerBuilding,
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
