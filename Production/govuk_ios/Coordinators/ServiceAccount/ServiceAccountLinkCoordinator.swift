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

    override func start() {
        showConsent()
    }

    private func showConsent() {
        // temporary placeholder landing screen
        // used as a root for presenting the authentication session
        let viewController = viewControllerBuilder.serviceAccountConsent(
            analyticsService: analyticsService,
            completionAction: authenticate,
            cancelAction: dismissModal
        )
        set(viewController)
    }

    private func authenticate() {
        let coordinator = coordinatorBuilder.dvlaAuthentication(
            navigationController: root,
            completion: linkAccount,
            errorAction: { error in
                if error != .userCancelled {
                    print("auth failed")
                }
            })
        start(coordinator)
    }

    private func linkAccount(linkId: String) {
        let viewController = viewControllerBuilder.serviceAccountLinking(
            userService: userService,
            accountType: accountType,
            linkId: linkId,
            completeAction: { [weak self] in
                print("dvla account linked successfully")
                self?.dismissModal()
                self?.completion(true)
            },
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
