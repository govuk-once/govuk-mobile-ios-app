import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct EditTopicsDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = EditTopicsDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/topics/edit")
    }
    
    @Test
    func action_EditTopics() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = EditTopicsDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)
        let mockCoodinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedHomeViewController = expectedViewController
        let navigationController = UINavigationController()
        let mockHomeCoordinator = MockHomeCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoodinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            deeplinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            topicsService: MockTopicsService(),
            notificationService: MockNotificationService(),
            deviceInformationProvider: MockDeviceInformationProvider(),
            searchService: MockSearchService(),
            activityService: MockActivityService(),
            localAuthorityService: MockLocalAuthorityService(),
            userDefaultsService: MockUserDefaultsService(),
            chatService: MockChatService()
        )
        #expect(mockHomeCoordinator._didEditTopics == false)
        subject.action(parent: mockHomeCoordinator, params: [:])
        #expect(mockHomeCoordinator._didEditTopics == true)
    }
}
