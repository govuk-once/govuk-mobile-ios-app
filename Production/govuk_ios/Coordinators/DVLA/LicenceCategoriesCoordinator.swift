import Foundation
import UIKit
import GovKit

final class LicenceCategoriesCoordinator: SheetNavigationCoordinator {
    private let viewControllerBuilder: DVLAViewControllerBuilding
    private let analyticsService: AnalyticsServiceInterface
    private let entitlements: [Entitlement]

    init(viewControllerBuilder: DVLAViewControllerBuilding,
         analyticsService: AnalyticsServiceInterface,
         entitlements: [Entitlement]) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.entitlements = entitlements
        super.init()
    }

    override func start(url: URL?) {
        showList()
    }

    private func showList() {
        let viewController = viewControllerBuilder.licenceCategoryList(
            entitlements: entitlements,
            analyticsService: analyticsService,
            selectAction: { [weak self] entitlement in
                self?.showDetail(entitlement: entitlement)
            },
            dismissAction: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        set(viewController, animated: false)
    }

    private func showDetail(entitlement: Entitlement) {
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
