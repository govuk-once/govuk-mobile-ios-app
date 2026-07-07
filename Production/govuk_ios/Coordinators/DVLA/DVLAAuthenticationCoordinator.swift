import Foundation
import UIKit
import GovKit

final class DVLAAuthenticationCoordinator: BaseCoordinator {
    private let authenticationUrl = {
        URL(string: "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")!
    }()
    private let urlOpener: URLOpener
    private let dvlaService: DVLAServiceInterface

    init(navigationController: UINavigationController,
         urlOpener: URLOpener,
         dvlaService: DVLAServiceInterface) {
        self.urlOpener = urlOpener
        self.dvlaService = dvlaService
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
        case .success(let email):
            authenticate(email: email)
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
            .init(name: "v", value: email)
        ]
        guard let url = components?.url
        else { return presentError() }
        urlOpener.openIfPossible(url)
    }

    private func presentError() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to link account",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        root.present(alert, animated: true)
    }
}
