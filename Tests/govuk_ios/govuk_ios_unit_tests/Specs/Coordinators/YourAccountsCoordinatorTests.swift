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

    @Test
    func start_unlinkErrorActionCalled_pushesUnlinkAccountsErrorView() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedSettingsVC = UIViewController()
        let expectedErrorVC = UIViewController()
        let navigationController = UINavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock

        mockViewControllerBuilder._stubbedYourAccountsViewController = expectedSettingsVC
        mockViewControllerBuilder._stubbedUnlinkErrorViewController = expectedErrorVC

        let sut = YourAccountsSettingsCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            userService: MockUserService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            unlinkErrorAction: {}
        )
        sut.start()
        mockViewControllerBuilder._receivedUnlinkErrorAction?()
        #expect(navigationController.viewControllers.count == 2)
        #expect(navigationController.viewControllers.last == expectedErrorVC)
    }
}
