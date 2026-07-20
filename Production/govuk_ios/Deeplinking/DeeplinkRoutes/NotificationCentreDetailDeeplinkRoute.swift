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
        guard let coordinator = coordinatorBuilder
            .notificationCentre(navigationController: parent.root)
                as? NotificationCentreCoordinator else { return }

        parent.root.popToRootViewController(animated: false)

        guard let id = params["id"] else { return }

        coordinator.showDetail(for: id)
    }
}
