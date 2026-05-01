import UIKit
import Foundation
import FactoryKit

extension CoordinatorBuilder {

    func localAuthenticationSettings(
        navigationController: UINavigationController
    ) -> BaseCoordinator {
        LocalAuthenticationSettingsCoordinator(
            navigationController: navigationController,
            authenticationService: container.authenticationService.resolve(),
            localAuthenticationService: container.localAuthenticationService.resolve(),
            analyticsService: container.analyticsService.resolve(),
            viewControllerBuilder: ViewControllerBuilder(),
            urlOpener: UIApplication.shared
        )
    }

    func notificationSettings(navigationController: UINavigationController,
                              completionAction: @escaping () -> Void,
                              dismissAction: @escaping () -> Void) -> BaseCoordinator {
        NotificationSettingsCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: ViewControllerBuilder(),
            analyticsService: container.analyticsService.resolve(),
            notificationService: container.notificationService.resolve(),
            coordinatorBuilder: self,
            completeAction: completionAction,
            dismissAction: dismissAction
        )
    }

    func signOutConfirmation() -> BaseCoordinator {
        SignOutConfirmationCoordinator(
            navigationController: UINavigationController(),
            viewControllerBuilder: ViewControllerBuilder(),
            authenticationService: container.authenticationService.resolve(),
            analyticsService: container.analyticsService.resolve()
        )
    }
}
