import Foundation
import GovKit
import SwiftUI
import UIKit

@MainActor
final class BenefitsContainerCoordinator: BaseCoordinator {
    private let viewControllerBuilder: BenefitsViewControllerBuilding

    init(
        navigationController: UINavigationController,
        viewControllerBuilder: BenefitsViewControllerBuilding) {
        self.viewControllerBuilder = viewControllerBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.makeBenefitsContainer()
        push(viewController)
    }
}
