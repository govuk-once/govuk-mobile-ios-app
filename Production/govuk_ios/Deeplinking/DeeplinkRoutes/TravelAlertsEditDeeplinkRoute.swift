import Foundation

struct TravelAlertsEditDeeplinkRoute: DeeplinkRoute {
    private let coordinatorBuilder: CoordinatorBuilder

    init(coordinatorBuilder: CoordinatorBuilder) {
        self.coordinatorBuilder = coordinatorBuilder
    }

    var pattern: URLPattern {
        "/travelalerts/edit"
    }

    @MainActor
    func action(parent: BaseCoordinator, params: [String: String]) {
        guard let homeCoordinator = parent as? HomeCoordinator else { return }
        parent.root.popToRootViewController(animated: false)
        homeCoordinator.showEditTravelAlertCountries()
    }
}
