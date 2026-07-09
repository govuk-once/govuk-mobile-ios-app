import Foundation
import UIKit
import GovKit

final class DVLAAuthenticationCoordinator: BaseCoordinator {
    private let authenticationUrl = {
        URL(string: "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")!
    }()
    private let urlOpener: URLOpener
    private let dvlaService: DVLAServiceInterface
    private let authenticationService: AuthenticationServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    init(navigationController: UINavigationController,
         urlOpener: URLOpener,
         dvlaService: DVLAServiceInterface,
         authenticationService: AuthenticationServiceInterface,
         analyticsService: AnalyticsServiceInterface) {
        self.urlOpener = urlOpener
        self.dvlaService = dvlaService
        self.authenticationService = authenticationService
        self.analyticsService = analyticsService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        Task {
            await fetchIdentityVerification()
        }
    }

    private func fetchIdentityVerification() async {
        let result = await authenticationService.fetchIdentityVerification()
        switch result {
        case .success(let result):
            authenticate(email: result.verificationHash)
        case .failure:
            presentError()
        }
    }

    private func authenticate(email: String) {
        var components = URLComponents(
            url: authenticationUrl,
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [
            .init(name: "verification", value: email)
        ]
        guard let url = components?.url
        else { return presentError() }
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
        let errorView = ErrorView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: errorView,
            navigationBarHidden: true
        )
        set(hostingViewController, animated: true)
    }
}
