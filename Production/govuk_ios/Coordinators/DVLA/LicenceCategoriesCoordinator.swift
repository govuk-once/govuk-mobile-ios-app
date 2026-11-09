import Foundation
import UIKit
import GovKit

final class LicenceCategoriesCoordinator: SheetNavigationCoordinator {
    private let viewControllerBuilder: DVLAViewControllerBuilding
    private let analyticsService: AnalyticsServiceInterface

    init(viewControllerBuilder: DVLAViewControllerBuilding,
         analyticsService: AnalyticsServiceInterface,
         entitlements: [Entitlement]) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        super.init { coordinator in
            let typedCoordinator = coordinator as? LicenceCategoriesCoordinator
            let viewModel = LicenceCategoryListViewModel(
                entitlements: entitlements,
                didSelectAction: { [weak typedCoordinator] entitlement in
                    typedCoordinator?.showDetail(entitlement: entitlement)
                },
                dismissAction: { [weak typedCoordinator] in
                    typedCoordinator?.dismiss(animated: true)
                }
            )
            return LicenceCategoriesListView(viewModel: viewModel)
        }
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
