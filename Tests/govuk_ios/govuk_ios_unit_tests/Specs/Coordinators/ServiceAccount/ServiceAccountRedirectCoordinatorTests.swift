import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ServiceAccountRedirectCoordinatorTests {
    @Test
    func start_setsLinkView() {
        let mockNavigationController = MockNavigationController()
        let mockAnalyticsService = MockAnalyticsService()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountLinkingController = expectedViewController
        let sut = ServiceAccountRedirectCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: mockAnalyticsService,
            userService: MockUserService(),
            accountType: .dvla,
            token: "test-token",
            notificationCenter: MockNotificationCenter()
        )
        sut.start()

        #expect(mockNavigationController._setViewControllers?.contains(expectedViewController) == true)
    }

    @Test
    func linkAccountComplete_showsLinkSuccess() {
        let mockNavigationController = MockNavigationController()
        let mockAnalyticsService = MockAnalyticsService()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockNotificationCenter = MockNotificationCenter()
        let sut = ServiceAccountRedirectCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: mockAnalyticsService,
            userService: MockUserService(),
            accountType: .dvla,
            token: "test-token",
            notificationCenter: mockNotificationCenter
        )
        sut.start()

        mockNavigationController._setViewControllers = nil
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountLinkSuccessController = expectedViewController

        mockViewControllerBuilder._receivedServiceAccountLinkingCompleteAction?()

        #expect(mockNavigationController._setViewControllers?.contains(expectedViewController) == true)
        #expect(mockNotificationCenter._receivedPostNames.count == 1)
    }

    @Test
    func linkAccountDismiss_dismissedView() {
        let mockNavigationController = MockNavigationController()
        let mockAnalyticsService = MockAnalyticsService()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockNotificationCenter = MockNotificationCenter()
        let sut = ServiceAccountRedirectCoordinator(
            navigationController: mockNavigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: mockAnalyticsService,
            userService: MockUserService(),
            accountType: .dvla,
            token: "test-token",
            notificationCenter: mockNotificationCenter
        )
        sut.start()

        mockNavigationController._setViewControllers = nil
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedServiceAccountLinkSuccessController = expectedViewController

        mockViewControllerBuilder._receivedServiceAccountLinkingDismissAction?()

        #expect(mockNavigationController._dismissCalled)
    }
}
