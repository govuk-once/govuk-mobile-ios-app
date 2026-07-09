import Foundation
import UIKit
import GovKit

final class DVLAAuthenticationCoordinator: BaseCoordinator {
    private let authenticationUrl = {
        URL(string: "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")!
    }()
    private let urlOpener: URLOpener
    private let dvlaService: DVLAServiceInterface
    private let analticsService: AnalyticsServiceInterface

    init(navigationController: UINavigationController,
         urlOpener: URLOpener,
         dvlaService: DVLAServiceInterface,
         analticsService: AnalyticsServiceInterface) {
        self.urlOpener = urlOpener
        self.dvlaService = dvlaService
        self.analticsService = analticsService
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        Task {
            await fetchIdentityVerification()
        }
    }

    private func fetchIdentityVerification() async {
        let result = await dvlaService.fetchIdentityVerification()
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
        let viewModel = ErrorViewModel(
            analyticsService: analticsService,
            title: "Something went wrong",
            subtitle: "Please try again later",
            systemImageName: "exclamationmark.circle",
            primaryButtonTitle: "I understand",
            primaryAction: { [weak self] in
                self?.root.dismiss(animated: true)
            },
            trackingName: ""
        )
        let errorView = ErrorView(viewModel: viewModel)
        let hostingViewController = HostingViewController(
            rootView: errorView,
            navigationBarHidden: true
        )
        set(hostingViewController, animated: true)
    }
}
