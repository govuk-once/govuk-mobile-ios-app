import Foundation

struct SearchDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/search"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        if let homeCoordinator = parent as? HomeCoordinator {
            if let homeVC = homeCoordinator.root.topViewController as? HomeViewController {
                homeVC.openSearch()
            }
        }
    }
}
