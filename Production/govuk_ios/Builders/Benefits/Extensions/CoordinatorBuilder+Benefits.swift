import UIKit
import SwiftUI
import GovKit
import Foundation
import FactoryKit

@MainActor
protocol BenefitsCoordinatorBuilding {
    func benefitsContainer(
        navigationController: UINavigationController,
        viewControllerBuilder: BenefitsViewControllerBuilding
    ) -> BaseCoordinator
}

@MainActor
extension CoordinatorBuilder: BenefitsCoordinatorBuilding {
    func benefitsContainer(
        navigationController: UINavigationController,
        viewControllerBuilder: BenefitsViewControllerBuilding
    ) -> BaseCoordinator {
        BenefitsContainerCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: viewControllerBuilder
        )
    }
}
