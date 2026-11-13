import Foundation
import UIKit
import GovKit

final class LicenceCategoriesCoordinator: BaseCoordinator {
    private var previousPrefersLargeTitles: Bool?
    private let viewControllerBuilder: DVLAViewControllerBuilding
    private let urlOpener: URLOpener
    private let configService: AppConfigServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let entitlements: [Entitlement]

    init(navigationController: UINavigationController,
         viewControllerBuilder: DVLAViewControllerBuilding,
         urlOpener: URLOpener,
         configService: AppConfigServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         entitlements: [Entitlement]) {
        self.viewControllerBuilder = viewControllerBuilder
        self.urlOpener = urlOpener
        self.configService = configService
        self.analyticsService = analyticsService
        self.entitlements = entitlements
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        assert(
            !root.viewControllers.isEmpty,
            "\(Self.self) must be pushed onto an existing navigation stack via start(_:), not presented modally."
        )
        previousPrefersLargeTitles = root.navigationBar.prefersLargeTitles
        root.navigationBar.prefersLargeTitles = true
        showList()
    }

    override func finish() {
        if let previousPrefersLargeTitles {
            root.navigationBar.prefersLargeTitles = previousPrefersLargeTitles
            self.previousPrefersLargeTitles = nil
        }
        super.finish()
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
        viewController.navigationItem.largeTitleDisplayMode = .always
        push(viewController)
    }

    private func showDetail(entitlement: Entitlement) {
        let viewController = viewControllerBuilder.licenceCategoryDetail(
            entitlement: entitlement,
            analyticsService: analyticsService,
            dismissAction: { [weak self] in
                self?.dismiss(animated: true)
            }
        )

        let navCon = UINavigationController(rootViewController: viewController)
        self.root.present(navCon, animated: true)
    }
}
