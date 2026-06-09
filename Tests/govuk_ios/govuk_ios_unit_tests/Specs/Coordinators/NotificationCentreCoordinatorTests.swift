import Foundation
import UIKit
import Testing
import GovKit

@testable import govuk_ios

@Suite
@MainActor
struct NotificationCentreCoordinatorTests {
    let navigationController = UINavigationController()
    var mockViewControllerBuilder: MockViewControllerBuilder!
    var mockCoordinatorBuilder: MockCoordinatorBuilder!
    var SUT: NotificationCentreCoordinator!

    init() {
        UIView.setAnimationsEnabled(false)
        mockViewControllerBuilder = MockViewControllerBuilder()
        mockCoordinatorBuilder = CoordinatorBuilder.mock

        SUT = NotificationCentreCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            notificationCentreService: MockNotificationCentreService(),
            analyticsService: MockAnalyticsService(),
            coordinatorBuilder: CoordinatorBuilder.mock)
    }

    @Test
    func start_setsNotificationCentreViewController() {
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationCentreViewController = expectedViewController

        SUT.start()

        #expect(navigationController.viewControllers.first == expectedViewController)
    }

    @Test
    func showDetail_setsNotificationCentreDetailViewController() throws {
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationCentreDetailViewController = expectedViewController

        SUT.showDetail(for: "1")

        #expect(navigationController.viewControllers.first == expectedViewController)
    }
}
