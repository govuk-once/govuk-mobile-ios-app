import Foundation
import GovKit
import SwiftUI
import UIKit

@MainActor
final class BenefitsContainerCoordinator: BaseCoordinator {
    private let viewControllerBuilder: BenefitsViewControllerBuilding
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface

    init(
        navigationController: UINavigationController,
        viewControllerBuilder: BenefitsViewControllerBuilding,
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.configService = configService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.makeBenefitsContainer()
        push(viewController)
    }
}
