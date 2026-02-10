import Foundation
import UIKit
import SwiftUI
import GovKit

class AnalyticsConsentCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let completion: () -> Void

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         completion: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard analyticsService.permissionState == .unknown
        else { return completion() }
        setAnalyticsConsent()
    }

    private func setAnalyticsConsent() {
        let viewController = viewControllerBuilder.analyticsConsent(
            analyticsService: analyticsService,
            userService: userService,
            completion: completion,
            viewPrivacyAction: { [weak self] in
                self?.openPrivacy()
            }
        )
        set(viewController)
    }

    private func openPrivacy() {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: Constants.API.privacyPolicyUrl,
            fullScreen: false
        )
        start(coordinator)
    }
}
