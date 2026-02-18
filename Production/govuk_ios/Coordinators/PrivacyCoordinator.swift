import UIKit
import Foundation
import GovKit

protocol PrivacyPresenting {
    func showPrivacyScreen()
    func hidePrivacyScreen()
    func showPrivacyAlert()
    func hidePrivacyAlert()
}

protocol PrivacyProviding { }

class PrivacyCoordinator: BaseCoordinator {
    override init(navigationController: UINavigationController) {
        navigationController.modalPresentationStyle = .fullScreen
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let view = PrivacyView()
        let viewController = HostingViewController(rootView: view)
        viewController.modalPresentationStyle = .fullScreen
        set(viewController, animated: false)
    }
}

extension PrivacyCoordinator: PrivacyProviding { }
