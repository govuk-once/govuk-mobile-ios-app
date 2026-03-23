import Foundation

struct RecentActivityDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/recent-activity"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        if let homeCoordinator = parent as? HomeCoordinator {
            homeCoordinator.startRecentActivityCoordinator()
        }
    }
}
