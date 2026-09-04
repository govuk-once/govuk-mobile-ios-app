import UIKit
import GovKit
import AuthenticationServices

final class FollowCountryCoordinator: BaseCoordinator {
    private let coordinatorBuilder: CoordinatorBuilder
    private let viewControllerBuilder: ViewControllerBuilder
    private let analyticsService: AnalyticsServiceInterface
    private let travelService: TravelServiceInterface
    private let userService: UserServiceInterface
    private let completion: (Bool) -> Void

    init(navigationController: UINavigationController,
         coordinatorBuilder: CoordinatorBuilder,
         viewControllerBuilder: ViewControllerBuilder,
         analyticsService: AnalyticsServiceInterface,
         travelService: TravelServiceInterface,
         userService: UserServiceInterface,
         completion: @escaping (Bool) -> Void) {
        self.coordinatorBuilder = coordinatorBuilder
        self.viewControllerBuilder = viewControllerBuilder
        self.analyticsService = analyticsService
        self.travelService = travelService
        self.userService = userService
        self.completion = completion
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        followACountry()
    }

    private func followACountry() {
        let viewController = viewControllerBuilder.followACountry(
            travelService: travelService,
            analyticsService: analyticsService,
            dismissAction: dismissModal
        )
        set(viewController)
    }

    private func dismissModal() {
        root.dismiss(animated: true, completion: nil)
    }
}
