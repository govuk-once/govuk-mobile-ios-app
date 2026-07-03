import Foundation
import UIKit

struct DVLAServiceDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/callback/dvla/auth"
    }

    @MainActor
    func action(parent: BaseCoordinator,
                params: [String: String]) {
        guard let token = params["token"]
        else { return }
        parent.root.dismiss(animated: false)
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = coordinatorBuilder.serviceAccountRedirect(
            navigationController: navigationController,
            accountType: .dvla,
            token: token,
        )
        parent.present(coordinator)
    }
}
