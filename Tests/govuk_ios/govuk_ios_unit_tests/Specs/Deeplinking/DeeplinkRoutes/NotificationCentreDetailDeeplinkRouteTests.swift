import FactoryKit
import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct NotificationCentreDetailDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = NotificationCentreDetailDeeplinkRoute(
            coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/notificationcentre/detail")
    }

    @Test
    func open_detail() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNotificationCentreCoordinator = MockNotificationCentreCoordinator(
            navigationController: UINavigationController(),
            viewControllerBuilder: MockViewControllerBuilder(),
            notificationCentreService: MockNotificationCentreService(),
            analyticsService: MockAnalyticsService(),
            coordinatorBuilder: mockCoordinatorBuilder)
        mockCoordinatorBuilder._stubbedNotificationCentreCoordinator = mockNotificationCentreCoordinator

        let subject = NotificationCentreDetailDeeplinkRoute(
            coordinatorBuilder: mockCoordinatorBuilder)

        #expect(mockNotificationCentreCoordinator._stubbedDidShowDetail == false)
        await subject.action(parent: mockCoordinatorBuilder._mockHomeCoordinator, params: ["id":"test"])
        #expect(mockNotificationCentreCoordinator._stubbedDidShowDetail == true)
    }
}
