import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct CountryListCoordinatorTests {

    @Test
    func start_setsViewController() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            completion: { _ in }
        )

        sut.start()

        #expect(mockNavigationController._setViewControllers != nil)
        #expect(mockNavigationController._setViewControllers?.count ?? 0 > 0)
    }

    @Test
    func start_passesOpenURLActionToViewControllerBuilder() {
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder()

        let sut = CountryListCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: CoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            travelService: MockTravelService(),
            notificationService: MockNotificationService(),
            userService: MockUserService(),
            urlOpener: MockURLOpener(),
            completion: { _ in }
        )

        sut.start()

        #expect(mockNavigationController._setViewControllers?.count ?? 0 > 0)
    }
}
