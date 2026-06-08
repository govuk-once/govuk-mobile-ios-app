import Foundation
import UIKit
import GovKit

final class ServiceAccountRedirectCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType
    private let token: String
    private let completion: (Bool) -> Void

    // To be removed
    private let authenticationService: DVLAAuthenticationServiceInterface

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         accountType: ServiceAccountType,
         token: String,
         authenticationService: DVLAAuthenticationServiceInterface,
         completion: @escaping (Bool) -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.userService = userService
        self.accountType = accountType
        self.completion = completion
        self.token = token
        self.authenticationService = authenticationService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        Task {
            await setLinkAccount()
        }
    }

    private func setLinkAccount() async {
        guard let id = try? await authenticationService.extractLinkId(from: token)
        else { return }
        let viewController = viewControllerBuilder.serviceAccountLinking(
            analyticsService: analyticsService,
            userService: userService,
            accountType: accountType,
            linkId: id,
            completeAction: { [weak self] in
                self?.showLinkSuccess()
            },
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func showLinkSuccess() {
        let viewController = viewControllerBuilder.serviceAccountLinkSuccess(
            analyticsService: analyticsService,
            accountType: accountType,
            completionAction: { [weak self] in
                self?.dismissModal()
                self?.completion(true)
            }
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
