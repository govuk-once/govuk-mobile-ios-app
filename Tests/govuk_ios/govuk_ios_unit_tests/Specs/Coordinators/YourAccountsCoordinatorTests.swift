import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct YourAccountsCoordinatorTests {

    @Test func navigateToYourAccounts_pushesYourAccountsViewController() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock

        mockViewControllerBuilder._stubbedYourAccountsViewController = expectedViewController

        let sut = YourAccountsSettingsCoordinator(
            navigationController: MockNavigationController(), viewControllerBuilder: MockViewControllerBuilder(),
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            dismissAction: {}
        )
        sut.start()
        #expect(navigationController.viewControllers.first == expectedViewController)
    }
}
