import Foundation

struct EditTopicsDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/edit-topics"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        if let homeCoordinator = parent as? HomeCoordinator {
            homeCoordinator.editTopics()
        }
    }
}
