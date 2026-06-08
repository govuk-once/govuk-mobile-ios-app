import Foundation
import UIKit

struct DVLAServiceDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder
    private let notificationCenter: NotificationCenter

    init(coordinatorBuilder: CoordinatorBuilder,
         notificationCenter: NotificationCenter) {
        self.coordinatorBuilder = coordinatorBuilder
        self.notificationCenter = notificationCenter
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
            completion: { success in
                guard success else { return }
                let notification = Notification.Name(rawValue: "dvla-account-linked")
                notificationCenter.post(name: notification, object: nil)
            }
        )
        parent.present(coordinator)
    }
}
