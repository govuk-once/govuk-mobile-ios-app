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

    @Test
    func backButton_callsDismissed() async {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = CoordinatorBuilder.mock
        let mockCoordinator = MockBaseCoordinator()

        mockViewControllerBuilder._stubbedYourAccountsViewController = expectedViewController

        var sut: YourAccountsSettingsCoordinator!
        let dismissed = await withCheckedContinuation { continuation in
            sut = YourAccountsSettingsCoordinator(
                navigationController: MockNavigationController(),
                viewControllerBuilder: MockViewControllerBuilder(),
                analyticsService: MockAnalyticsService(),
                userService: MockUserService(),
                coordinatorBuilder: mockCoordinatorBuilder,
                dismissAction: {
                    continuation.resume(returning: true)

                }
            )
            mockCoordinator.start(sut)
            mockViewControllerBuilder._receivedLocalAuthorityExplainerDismissAction?()
        }
        mockViewControllerBuilder._receivedYourAccountsViewDismissAction?()
        #expect(dismissed)
        #expect(mockCoordinator._childDidFinishReceivedChild == sut)
        #expect(sut != nil)
        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
    }

}
