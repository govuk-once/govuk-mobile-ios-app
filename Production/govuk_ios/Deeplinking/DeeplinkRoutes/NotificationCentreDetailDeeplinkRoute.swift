//


import Foundation

struct NotificationCentreDetailDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/notificationcentre/detail"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        let coordinator = coordinatorBuilder
            .notificationCenterCoordinator(navigationController: parent.root)

        parent.root.popToRootViewController(animated: false)

        guard let id = params["id"] else { return }

        coordinator.showDetail(for: id)
    }
}
