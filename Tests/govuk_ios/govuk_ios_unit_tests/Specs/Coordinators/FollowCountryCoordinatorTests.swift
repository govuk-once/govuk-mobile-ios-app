import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct FollowCountryCoordinatorTests {

    @Test
    func start_setsSelectCountryViewController() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedSelectCountryViewController = expectedViewController

        let sut = FollowCountryCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            completion: { _ in }
        )

        sut.start()

        #expect(mockNavigationController._setViewControllers?.first == expectedViewController)
    }

    @Test
    func dismissAction_dismissesModal() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = FollowCountryCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            userService: MockUserService(),
            completion: { _ in }
        )

        sut.start()
        mockViewControllerBuilder._receivedSelectCountryDismissAction?()

        #expect(mockNavigationController._dismissCalled)
        #expect(mockNavigationController._receivedDismissAnimated == true)
    }
}
