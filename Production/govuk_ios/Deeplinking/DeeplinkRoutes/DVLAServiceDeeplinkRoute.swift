import Foundation
import UIKit

struct DVLAServiceDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/returnedToken"
    }

    @MainActor
    func action(parent: BaseCoordinator,
                params: [String: String]) {
        guard let token = params["token"]
        else { return }
        parent.root.dismiss(animated: false)
        let navigationController = UINavigationController()
        let coordinator = coordinatorBuilder.serviceAccountRedirect(
            navigationController: navigationController,
            accountType: .dvla,
            token: token,
        )
        parent.present(coordinator)
    }
}
