//


import Foundation

struct NotificationCentreDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/notificationcentre"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        let coordinator = coordinatorBuilder
            .notificationCenterCoordinator(navigationController: parent.root)

        parent.root.popToRootViewController(animated: false)

        coordinator.start()
    }
}
