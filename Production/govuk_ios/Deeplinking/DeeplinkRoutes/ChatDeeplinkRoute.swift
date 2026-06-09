import Foundation

struct ChatDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/chat"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        guard let parent = parent as? ChatCoordinator else { return }
        parent.showChatOnboardingIfNecessary()
    }
}
