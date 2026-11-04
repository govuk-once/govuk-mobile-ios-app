import Foundation
import UIKit
import GovKit

final class LicenceCategoriesCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface

    private let entitlements: [Entitlement]

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         entitlements: [Entitlement]) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.entitlements = entitlements
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        // the category list should be pushed here - when it is built
        // for now just show an entitlement at random
        guard let entitlement = entitlements.randomElement() else { return }
        let viewController = viewControllerBuilder.licenceCategoryDetail(
            entitlement: entitlement,
            analyticsService: analyticsService,
            dismissAction: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        push(viewController)
    }
}
