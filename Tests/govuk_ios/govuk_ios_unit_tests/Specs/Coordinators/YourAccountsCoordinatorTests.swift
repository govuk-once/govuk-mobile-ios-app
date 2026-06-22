import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct YourAccountsCoordinatorTests {

    @Test func start_pushesYourAccountsViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock

        mockViewControllerBuilder._stubbedYourAccountsViewController = expectedViewController

        let sut = YourAccountsSettingsCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            unlinkErrorAction: {}
        )
        sut.start()
        #expect(navigationController.viewControllers.first == expectedViewController)
    }
}
