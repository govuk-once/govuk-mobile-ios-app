import UIKit
import Foundation
import GovKit

final class SARSettingsCoordinator: BaseCoordinator {
    private let analyticsService: AnalyticsServiceInterface
    private let userService: UserServiceInterface
    private let viewControllerBuilder: ViewControllerBuilder
    private(set) var userState: UserState?

    init(navigationController: UINavigationController,
         analyticsService: AnalyticsServiceInterface,
         viewControllerBuilder: ViewControllerBuilder,
         userService: UserServiceInterface) {
        self.analyticsService = analyticsService
        self.userService = userService
        self.viewControllerBuilder = viewControllerBuilder
        super.init(navigationController: navigationController)
    }

    override func start(url: URL?) {
        let viewController = viewControllerBuilder.sarSettings(
            analyticsService: analyticsService
        ) { [weak self] in
            self?.userService.fetchUserState { userState in
                switch userState {
                case .success(let userState):
                    self?.userState = userState
                    print("User state = \(userState)")
                case .failure(let error):
                    print("user state error: \(error.localizedDescription)")
                }
            }
        }
        push(viewController)
    }
}
