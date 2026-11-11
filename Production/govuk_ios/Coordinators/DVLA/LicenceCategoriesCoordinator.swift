import Foundation
import UIKit
import GovKit

final class LicenceCategoriesCoordinator: BaseCoordinator {
    private let viewControllerBuilder: DVLAViewControllerBuilding
    private let urlOpener: URLOpener
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let entitlements: [Entitlement]

    init(viewControllerBuilder: DVLAViewControllerBuilding,
         urlOpener: URLOpener,
         configService: AppConfigServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         entitlements: [Entitlement]) {
        self.viewControllerBuilder = viewControllerBuilder
        self.urlOpener = urlOpener
        self.configService = configService
        self.analyticsService = analyticsService
        self.entitlements = entitlements
        super.init(navigationController: UINavigationController())
    }

    override func start(url: URL?) {
        showList()
    }

    private func showList() {
        let actions = CategoriesActions(
            didSelectAction: { [weak self] entitlement in
                self?.showDetail(entitlement: entitlement)
            },
            openURLAction: { [weak self] url in
                self?.urlOpener.openIfPossible(url)
            },
            dismissAction: { [weak self] in
                self?.dismiss(animated: true)
            }
        )

        let viewController = viewControllerBuilder.licenceCategoryList(
            entitlements: entitlements,
            analyticsService: analyticsService,
            configService: configService,
            actions: actions
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
