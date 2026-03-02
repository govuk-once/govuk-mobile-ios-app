import Foundation
import Testing
import FactoryKit
import UIKit

@testable import govuk_ios

@Suite
@MainActor
struct PostAuthCoordinatorTests {

    @Test
    func start_startsNotificationConsentCheck() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            remoteConfigService: MockRemoteConfigService(),
            navigationController: MockNavigationController(),
            completion: { }
        )
        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator

        let notificationConsentCoordinatorStartCalled = await withCheckedContinuation { continuation in
            mockNotificationConsentCoordinator._startCalledAction = {
                continuation.resume(returning: true)
            }
            subject.start(url: nil)
        }
        #expect(notificationConsentCoordinatorStartCalled == true)
    }

    @Test
    func notificationConsentCheckCompletion_startsAnalyticsConsent() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockNotificationService = MockNotificationService()
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(), 
            remoteConfigService: MockRemoteConfigService(),
            navigationController: MockNavigationController(),
            completion: { }
        )
        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator
        mockNotificationConsentCoordinator._startCalledAction = {
            mockCoordinatorBuilder._receivedNotificationConsentCompletion?()
        }

        let mockAnalyticsConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedAnalyticsConsentCoordinator = mockAnalyticsConsentCoordinator
        mockNotificationService._stubbedFetchConsentAlignmentResult = .aligned

        let analyticsConsentCoordinatorStartCalled = await withCheckedContinuation { continuation in
            mockAnalyticsConsentCoordinator._startCalledAction = {
                continuation.resume(returning: true)
            }
            subject.start(url: nil)
        }
        #expect(analyticsConsentCoordinatorStartCalled == true)
    }
    
    @Test
    func analyticsConsentCompletion_whenConsentAccepted_triggersRemoteConfigActivation() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockRemoteConfigService = MockRemoteConfigService()
        let mockAnalyticsService = MockAnalyticsService()
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            remoteConfigService: mockRemoteConfigService,
            navigationController: MockNavigationController(),
            completion: { }
        )

        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator
        mockNotificationConsentCoordinator._startCalledAction = {
            mockCoordinatorBuilder._receivedNotificationConsentCompletion?()
            mockCoordinatorBuilder._receivedAnalyticsConsentCompletion?()
        }

        mockAnalyticsService._stubbedPermissionState = .accepted

        await withCheckedContinuation { continuation in
            mockRemoteConfigService._activateCompletionBlock = {
                continuation.resume()
            }
            subject.start(url: nil)
        }

        #expect(mockRemoteConfigService._activateCallCount == 1)
    }

    @Test
    func analyticsConsentCompletion_whenConsentDenied_doesNotTriggerRemoteConfigActivation() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockRemoteConfigService = MockRemoteConfigService()
        let mockAnalyticsService = MockAnalyticsService()
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: mockAnalyticsService,
            notificationService: MockNotificationService(),
            remoteConfigService: mockRemoteConfigService,
            navigationController: MockNavigationController(),
            completion: { }
        )
        mockAnalyticsService._stubbedPermissionState = .denied
        let mockTopicOnboardingCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedTopicOnboardingCoordinator = mockTopicOnboardingCoordinator

        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator

        await withCheckedContinuation { continuation in
            mockNotificationConsentCoordinator._startCalledAction = {
                mockCoordinatorBuilder._receivedNotificationConsentCompletion?()
                mockCoordinatorBuilder._receivedAnalyticsConsentCompletion?()
                continuation.resume()
            }
            subject.start(url: nil)
        }

        #expect(mockRemoteConfigService._activateCallCount == 0)
        #expect(mockTopicOnboardingCoordinator._startCalled)
    }

    @Test
    func analyticsConsentCompletion_startsTopicOnboarding() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockRemoteConfigService = MockRemoteConfigService()
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            remoteConfigService: mockRemoteConfigService,
            navigationController: MockNavigationController(),
            completion: { }
        )
        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator
        mockNotificationConsentCoordinator._startCalledAction = {
            mockCoordinatorBuilder._receivedNotificationConsentCompletion?()
            mockCoordinatorBuilder._receivedAnalyticsConsentCompletion?()
        }

        let mockTopicOnboardingCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedTopicOnboardingCoordinator = mockTopicOnboardingCoordinator

        await withCheckedContinuation { continuation in
            mockRemoteConfigService._activateCompletionBlock = {
                continuation.resume()
            }
            subject.start(url: nil)
        }

        #expect(mockTopicOnboardingCoordinator._startCalled)
    }

    @Test
    func topicsOnboardingCompletion_startsNotificationOnboarding() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockRemoteConfigService = MockRemoteConfigService()
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            remoteConfigService: mockRemoteConfigService,
            navigationController: MockNavigationController(),
            completion: { }
        )
        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator
        mockNotificationConsentCoordinator._startCalledAction = {
            mockCoordinatorBuilder._receivedNotificationConsentCompletion?()
            mockCoordinatorBuilder._receivedAnalyticsConsentCompletion?()
        }

        let mockTopicOnboardingCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedTopicOnboardingCoordinator = mockTopicOnboardingCoordinator

        await withCheckedContinuation { continuation in
            mockRemoteConfigService._activateCompletionBlock = {
                continuation.resume()
            }
            subject.start(url: nil)
        }

        mockCoordinatorBuilder._receivedTopicOnboardingDidDismissAction?()

        #expect(mockTopicOnboardingCoordinator._startCalled)
    }

    @Test
    func notificationOnboardingCompletion_completesCoordinator() async {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockRemoteConfigService = MockRemoteConfigService()
        var completionCalled = false
        let subject = PostAuthCoordinator(
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            notificationService: MockNotificationService(),
            remoteConfigService: mockRemoteConfigService,
            navigationController: MockNavigationController(),
            completion: {
                completionCalled = true
            }
        )
        let mockNotificationConsentCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedNotificationConsentCoordinator = mockNotificationConsentCoordinator
        mockNotificationConsentCoordinator._startCalledAction = {
            mockCoordinatorBuilder._receivedNotificationConsentCompletion?()
            mockCoordinatorBuilder._receivedAnalyticsConsentCompletion?()
        }

        let mockTopicOnboardingCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedTopicOnboardingCoordinator = mockTopicOnboardingCoordinator

        await withCheckedContinuation { continuation in
            mockRemoteConfigService._activateCompletionBlock = {
                continuation.resume()
            }
            subject.start(url: nil)
        }

        mockCoordinatorBuilder._receivedTopicOnboardingDidDismissAction?()
        mockCoordinatorBuilder._receivedNotificationOnboardingCompletion?()

        #expect(completionCalled)
    }
    
}
