import Foundation
import UIKit
import GovKit

final class DVLAAuthenticationCoordinator: BaseCoordinator {
    private let authenticationUrl = {
        URL(string: "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")!
    }()
    private let urlOpener: URLOpener

    init(navigationController: UINavigationController,
         urlOpener: URLOpener) {
        self.urlOpener = urlOpener
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        authenticate()
    }

    private func authenticate() {
        urlOpener.openIfPossible(authenticationUrl)
    }
}
