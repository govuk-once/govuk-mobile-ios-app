import Foundation
import UIKit
import GovKit

final class ServiceAccountRedirectCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let accountType: ServiceAccountType
    private let notificationCenter: NotificationCenter
    private let token: String

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         userService: UserServiceInterface,
         accountType: ServiceAccountType,
         token: String,
         notificationCenter: NotificationCenter) {
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.userService = userService
        self.accountType = accountType
        self.token = token
        self.notificationCenter = notificationCenter
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        setLinkAccount()
    }

    private func setLinkAccount() {
        let viewController = viewControllerBuilder.serviceAccountLinking(
            analyticsService: analyticsService,
            userService: userService,
            accountType: accountType,
            token: token,
            completeAction: { [weak self] in
                self?.setLinkSuccess()
                self?.postLinkSuccess()
            },
            dismissAction: dismissModal,
        )
        set(viewController)
    }

    private func setLinkSuccess() {
        let viewController = viewControllerBuilder.serviceAccountLinkSuccess(
            analyticsService: analyticsService,
            accountType: accountType,
            completionAction: { [weak self] in
                self?.dismissModal()
            }
        )
        set(viewController)
    }

    private func postLinkSuccess() {
        let notification = Foundation.Notification.Name(rawValue: "dvla-account-linked")
        notificationCenter.post(name: notification, object: nil)
    }

    private func dismissModal() {
        root.dismiss(animated: true)
    }
}
