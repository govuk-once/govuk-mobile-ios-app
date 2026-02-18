import Foundation
import Testing
import UIKit

@testable import govuk_ios

@Suite
class NotificationOnboardingCoordinatorTests {
    @Test
    @MainActor
    func start_shouldRequestPermission_startsOnboarding() async {
        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder.mock
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationOnboardingService.hasSeenNotificationsOnboarding = false
        mockNotificationService._stubbedShouldRequestPermission = true
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationOnboardingViewController = expectedViewController
        await withCheckedContinuation { continuation in
            let sut = NotificationOnboardingCoordinator(
                navigationController: mockNavigationController,
                notificationService: mockNotificationService,
                notificationOnboardingService: mockNotificationOnboardingService,
                analyticsService: MockAnalyticsService(),
                userService: MockUserService(),
                viewControllerBuilder: mockViewControllerBuilder,
                coordinatorBuilder: MockCoordinatorBuilder.mock,
                completion: { }
            )
            mockNotificationService._stubbedShouldRequestPermission = true
            mockNavigationController._setViewControllersCalledAction = {
                continuation.resume()
            }
            sut.start(url: nil)
        }
        #expect(mockNavigationController._setViewControllers?.first == expectedViewController)
    }

    @Test
    @MainActor
    func start_notificationConsentCompleteAction_callsUserServiceSetConsent() async {
        let mockUserService = MockUserService()

        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder.mock
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationOnboardingService.hasSeenNotificationsOnboarding = false
        mockNotificationService._stubbedShouldRequestPermission = true
        let stubbedNotificationOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationOnboardingViewController = stubbedNotificationOnboardingViewController

        let sut = NotificationOnboardingCoordinator(
            navigationController: mockNavigationController,
            notificationService: mockNotificationService,
            notificationOnboardingService: mockNotificationOnboardingService,
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            viewControllerBuilder: mockViewControllerBuilder,
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            completion: { }
        )
        mockNotificationService._stubbedShouldRequestPermission = true

        await withCheckedContinuation { continuation in
            mockNavigationController._setViewControllersCalledAction = {
                continuation.resume()
            }
            sut.start(url: nil)
        }

        mockViewControllerBuilder._receivedNotificationOnboardingCompleteAction?()
        mockNotificationService._stubbedhasGivenConsent = true
        mockNotificationService._receivedRequestPermissionsCompletion?(true)
        #expect(mockUserService._receivedNotificationConsent == .accepted)
    }

    @Test
    @MainActor
    func start_notificationConsentDismissAction_callsUserServiceSetConsent() async {
        let mockUserService = MockUserService()

        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockViewControllerBuilder = MockViewControllerBuilder.mock
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationOnboardingService.hasSeenNotificationsOnboarding = false
        mockNotificationService._stubbedShouldRequestPermission = true
        let stubbedNotificationOnboardingViewController = UIViewController()
        mockViewControllerBuilder._stubbedNotificationOnboardingViewController = stubbedNotificationOnboardingViewController

        let sut = NotificationOnboardingCoordinator(
            navigationController: mockNavigationController,
            notificationService: mockNotificationService,
            notificationOnboardingService: mockNotificationOnboardingService,
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            viewControllerBuilder: mockViewControllerBuilder,
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            completion: { }
        )
        mockNotificationService._stubbedShouldRequestPermission = true

        await withCheckedContinuation { continuation in
            mockNavigationController._setViewControllersCalledAction = {
                continuation.resume()
            }
            sut.start(url: nil)
        }

        mockViewControllerBuilder._receivedNotificationOnboardingDismissAction?()
        #expect(mockUserService._receivedNotificationConsent == .denied)
    }

    @Test
    @MainActor
    func start_userNotificationConsentUnknownAndOnboardingSeen_callsUserServiceSetConsent() async {
        let mockUserService = MockUserService()
        mockUserService._stubbedNotificationsConsentStatus = .unknown
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationOnboardingService.hasSeenNotificationsOnboarding = true
        let mockNotificationService = MockNotificationService()
        mockNotificationService._stubbedhasGivenConsent = true

        let mockNavigationController = MockNavigationController()

        let sut = NotificationOnboardingCoordinator(
            navigationController: mockNavigationController,
            notificationService: mockNotificationService,
            notificationOnboardingService: mockNotificationOnboardingService,
            analyticsService: MockAnalyticsService(),
            userService: mockUserService,
            viewControllerBuilder: MockViewControllerBuilder(),
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            completion: { }
        )

        await withCheckedContinuation { continuation in
            mockUserService._setNotificationConsentCompletionBlock = {
                continuation.resume()
            }
            sut.start(url: nil)
        }
        #expect(mockUserService._receivedNotificationConsent == .accepted)

    }

    @Test
    @MainActor
    func start_shouldRequestPermissionFalse_completesCoordinator() async {
        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationService._stubbedShouldRequestPermission = false
        let completed = await withCheckedContinuation { continuation in
            let sut = NotificationOnboardingCoordinator(
                navigationController: mockNavigationController,
                notificationService: mockNotificationService,
                notificationOnboardingService: mockNotificationOnboardingService,
                analyticsService: MockAnalyticsService(),
                userService: MockUserService(),
                viewControllerBuilder: MockViewControllerBuilder(),
                coordinatorBuilder: MockCoordinatorBuilder.mock,
                completion: {
                    continuation.resume(returning: true)
                }
            )
            sut.start(url: nil)
        }
        #expect(completed)
        #expect(mockNavigationController._setViewControllers == nil)
    }

    @Test
    @MainActor
    func start_whenPermissionNotRequiredAndOnboardingNotSeen_completesImmediately() async {
        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationService._stubbedShouldRequestPermission = false
        let completed = await withCheckedContinuation { continuation in
            let sut = NotificationOnboardingCoordinator(
                navigationController: mockNavigationController,
                notificationService: mockNotificationService,
                notificationOnboardingService: mockNotificationOnboardingService,
                analyticsService: MockAnalyticsService(),
                userService: MockUserService(),
                viewControllerBuilder: MockViewControllerBuilder(),
                coordinatorBuilder: MockCoordinatorBuilder.mock,
                completion: {
                    continuation.resume(returning: true)
                }
            )
            sut.start(url: nil)
        }
        #expect(completed)
        #expect(mockNavigationController._setViewControllers == nil)
    }

    @Test
    @MainActor
    func start_whenPermissionNotRequiredAndOnboardingSeen_completesImmediately() async {
        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationService._stubbedShouldRequestPermission = false
        let completed = await withCheckedContinuation { continuation in
            let sut = NotificationOnboardingCoordinator(
                navigationController: mockNavigationController,
                notificationService: mockNotificationService,
                notificationOnboardingService: mockNotificationOnboardingService,
                analyticsService: MockAnalyticsService(),
                userService: MockUserService(),
                viewControllerBuilder: MockViewControllerBuilder(),
                coordinatorBuilder: MockCoordinatorBuilder.mock,
                completion: {
                    continuation.resume(returning: true)
                }
            )
            sut.start(url: nil)
        }
        #expect(completed)
        #expect(mockNavigationController._setViewControllers == nil)
    }

    @Test
    @MainActor
    func viewPrivacyAction_startsSafari() async {
        let mockNotificationService = MockNotificationService()
        let mockNavigationController = MockNavigationController()
        let mockNotificationOnboardingService = MockNotificationsOnboardingService()
        mockNotificationOnboardingService.hasSeenNotificationsOnboarding = false
        mockNotificationService._stubbedShouldRequestPermission = true

        let mockViewControllerBuilder = MockViewControllerBuilder.mock
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator

        await withCheckedContinuation { continuation in
            let sut = NotificationOnboardingCoordinator(
                navigationController: mockNavigationController,
                notificationService: mockNotificationService,
                notificationOnboardingService: mockNotificationOnboardingService,
                analyticsService: MockAnalyticsService(),
                userService: MockUserService(),
                viewControllerBuilder: mockViewControllerBuilder,
                coordinatorBuilder: mockCoordinatorBuilder,
                completion: { }
            )

            mockSafariCoordinator._startCalledAction = {
                continuation.resume()
            }
            mockNavigationController._setViewControllersCalledAction = {
                mockViewControllerBuilder._receivedNotificationOnboardingViewPrivacyAction?()
            }
            sut.start(url: nil)
        }

        #expect(mockSafariCoordinator._startCalled)
    }
}
