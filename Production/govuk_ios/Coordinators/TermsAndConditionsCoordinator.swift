import SwiftUI
import GovKit

final class TermsAndConditionsCoordinator: BaseCoordinator {
    private let viewControllerBuilder: ViewControllerBuilder
    private let coordinatorBuilder: CoordinatorBuilder
    private let authenticationService: AuthenticationServiceInterface
    private let termsAndConditionsService: TermsAndConditionsServiceInterface
    private let completion: () -> Void

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         coordinatorBuilder: CoordinatorBuilder,
         authenticationService: AuthenticationServiceInterface,
         termsAndConditionsService: TermsAndConditionsServiceInterface,
         completion: @escaping () -> Void) {
        self.viewControllerBuilder = viewControllerBuilder
        self.coordinatorBuilder = coordinatorBuilder
        self.authenticationService = authenticationService
        self.termsAndConditionsService = termsAndConditionsService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        guard !termsAndConditionsService.termsAcceptanceIsValid else {
            completion()
            return
        }
        set([termsViewController], animated: false)
    }

    private func presentWebView(url: URL) {
        let coordinator = coordinatorBuilder.safari(
            navigationController: root,
            url: url,
            fullScreen: true
        )
        start(coordinator, url: url)
    }

    private var termsViewController: UIViewController {
        return viewControllerBuilder.termsAndConditions(
            termsAndConditionsService: termsAndConditionsService,
            completionAction: completion,
            alertDismissAction: { [weak self] in
                self?.authenticationService.signOut(reason: .userSignout)
            },
            openURLAction: { [weak self] url in
                self?.presentWebView(url: url)
            }
        )
    }
}
