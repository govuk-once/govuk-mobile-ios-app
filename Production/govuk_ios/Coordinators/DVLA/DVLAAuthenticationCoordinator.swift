import Foundation
import UIKit
import GovKit

final class DVLAAuthenticationCoordinator: BaseCoordinator {
    private let urlOpener: URLOpener
    private let authenticationService: AuthenticationServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let appEnvironmentService: AppEnvironmentServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder

    init(navigationController: UINavigationController,
         viewControllerBuilder: ViewControllerBuilder,
         urlOpener: URLOpener,
         authenticationService: AuthenticationServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         appEnvironmentService: AppEnvironmentServiceInterface) {
        self.urlOpener = urlOpener
        self.authenticationService = authenticationService
        self.analyticsService = analyticsService
        self.appEnvironmentService = appEnvironmentService
        self.viewControllerBuilder = viewControllerBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        pushLoadingView()
    }

    private func pushLoadingView() {
        let viewController = viewControllerBuilder.dvlaAuthentication(
            authenticationService: authenticationService,
            appEnvironmentService: appEnvironmentService,
            completionAction: { [weak self] url in
                self?.openUrl(url)
            },
            errorAction: { [weak self] in
                self?.presentError()
            }
        )
        push(viewController, animated: false)
    }

    private func openUrl(_ url: URL) {
        root.popViewController(animated: false)
        urlOpener.openIfPossible(url)
    }

    private func presentError() {
        let screenTitle = String.common
            .localized("genericErrorTitle")
        let screenSubtitle = String.dvla
            .localized("genericErrorTryAgainSubtitle")
        let primaryButtonTitle = String.dvla
            .localized("accountLinkingErrorPrimaryButtonTitle")

        let viewModel = ErrorViewModel(
            analyticsService: analyticsService,
            title: screenTitle,
            subtitle: screenSubtitle,
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: { [weak self] in
                self?.root.dismiss(animated: true)
            },
            trackingName: screenTitle,
        )
        let viewController = viewControllerBuilder.error(viewModel: viewModel)
        set(viewController, animated: true)
    }
}
