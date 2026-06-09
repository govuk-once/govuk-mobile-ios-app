import UIKit
import GovKit
import AuthenticationServices

final class ServiceAccountLinkCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType
    private let completion: (Bool) -> Void

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         accountType: ServiceAccountType,
         completion: @escaping (Bool) -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.userService = userService
        self.accountType = accountType
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        setConsent()
    }

    private func setConsent() {
        let viewController = viewControllerBuilder.serviceAccountConsent(
            analyticsService: analyticsService,
            accountType: accountType,
            completionAction: authenticate,
            cancelAction: dismissModal
        )
        set(viewController)
    }

    private func authenticate() {
        let coordinator = coordinatorBuilder.dvlaAuthentication(
            navigationController: root
        )
        start(coordinator)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
