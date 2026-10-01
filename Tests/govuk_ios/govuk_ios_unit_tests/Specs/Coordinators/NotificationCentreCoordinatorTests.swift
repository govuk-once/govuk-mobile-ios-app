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
            coordinatorBuilder: mockCoordinatorBuilder,
            urlOpener: MockURLOpener())
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

    @Test
    func showDetail_govukUrl_startsSafariCoordinator() {
        let govukUrl = URL(string: "govuk://app.gov.uk/travelalerts/edit")
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationCentreDetailViewController = expectedViewController
        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator

        SUT.showDetail(for: "1")

        guard let actions = mockViewControllerBuilder._capturedNotificationCentreDetailActions else {
            Issue.record("Expected actions to be set")
            return
        }

        actions.showUrlAction(govukUrl!)

        #expect(SUT.childCoordinators.contains(mockSafariCoordinator))
    }

    @Test
    func showDetail_httpUrl_startsSafariCoordinator() {
        let httpUrl = URL(string: "https://www.example.com")!
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationCentreDetailViewController = expectedViewController
        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator

        SUT.showDetail(for: "1")

        guard let actions = mockViewControllerBuilder._capturedNotificationCentreDetailActions else {
            Issue.record("Expected actions to be set")
            return
        }

        actions.showUrlAction(httpUrl)

        #expect(SUT.childCoordinators.contains(mockSafariCoordinator))
    }
}
