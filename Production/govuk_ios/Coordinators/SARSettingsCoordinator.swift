import UIKit
import Foundation
import GovKit

final class SARSettingsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder
    private(set) var userState: UserState?

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.viewControllerBuilder = viewControllerBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.sarExplainer(
            analyticsService: analyticsService
        ) { [weak self] in
            self?.pushResultView()
        }
        push(viewController)
    }

    private func pushResultView() {
        let viewController = viewControllerBuilder.sarResults(
            analyticsService: analyticsService,
            userService: userService,
            sarResultAction: { [weak self] in
                self?.root.popToRootViewController(animated: true)
                self?.finish()
            }
        )
        push(viewController)
    }
}
