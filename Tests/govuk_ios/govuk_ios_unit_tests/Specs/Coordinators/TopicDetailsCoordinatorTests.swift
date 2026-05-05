import UIKit
import Foundation
import Testing
import SafariServices

@testable import govuk_ios

@Suite
struct TopicDetailsCoordinatorTests {
    @MainActor
    @Test
    func start_setsTopicDetailViewController() throws {
        let coreData = CoreDataRepository.arrangeAndLoad
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockAnalyticsService = MockAnalyticsService()
        let mockTopicsService = MockTopicsService()
        let mockActivityService = MockActivityService()
        let expectedViewController = UIViewController()
        let navigationController = UINavigationController()

        mockViewControllerBuilder._stubbedTopicDetailViewController = expectedViewController

        let subject = TopicDetailsCoordinator(
            navigationController: navigationController,
            analyticsService: mockAnalyticsService,
            topicsService: mockTopicsService,
            activityService: mockActivityService,
            coordinatorBuilder: MockCoordinatorBuilder.mock,
            viewControllerBuilder: mockViewControllerBuilder,
            topic: Topic(context: coreData.viewContext)
        )

        subject.start()

        #expect(navigationController.viewControllers.first == expectedViewController)
    }

    @Test
    @MainActor
    func openAction_startsSafari() throws {
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoreDataRepository = CoreDataRepository.arrangeAndLoad
        let topic = Topic.arrange(context: mockCoreDataRepository.viewContext)
        let subject = TopicDetailsCoordinator(
            navigationController: mockNavigationController,
            analyticsService: MockAnalyticsService(),
            topicsService: MockTopicsService(),
            activityService: MockActivityService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            topic: topic
        )
        subject.start()
        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator
        let url = URL.arrange
        mockViewControllerBuilder._receivedTopicDetailOpenAction?(url)

        #expect(mockCoordinatorBuilder._receivedSafariCoordinatorURL == url)
        #expect(mockSafariCoordinator._startCalled)
    }

    @Test
    @MainActor
    func stepByStepAction_pushesStepBySteps() throws {
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedStepByStepsViewController = UIViewController()
        mockViewControllerBuilder._stubbedStepByStepViewController = expectedStepByStepsViewController
        let mockCoreDataRepository = CoreDataRepository.arrangeAndLoad
        let topic = Topic.arrange(context: mockCoreDataRepository.viewContext)
        let subject = TopicDetailsCoordinator(
            navigationController: mockNavigationController,
            analyticsService: MockAnalyticsService(),
            topicsService: MockTopicsService(),
            activityService: MockActivityService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            topic: topic
        )

        subject.start()

        let expectedContent = TopicDetailResponse.Content.arrange
        mockViewControllerBuilder._receivedTopicDetailStepByStepAction?([expectedContent])

        #expect(mockNavigationController._pushedViewController == expectedStepByStepsViewController)
        #expect(mockViewControllerBuilder._receivedStepByStepContent?.first?.url == expectedContent.url)
    }

    @Test
    @MainActor
    func stepByStep_OpenAction_startsSafari() throws {
        let mockNavigationController = MockNavigationController()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedStepByStepsViewController = UIViewController()
        mockViewControllerBuilder._stubbedStepByStepViewController = expectedStepByStepsViewController
        let mockCoreDataRepository = CoreDataRepository.arrangeAndLoad
        let topic = Topic.arrange(context: mockCoreDataRepository.viewContext)
        let subject = TopicDetailsCoordinator(
            navigationController: mockNavigationController,
            analyticsService: MockAnalyticsService(),
            topicsService: MockTopicsService(),
            activityService: MockActivityService(),
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            topic: topic
        )

        subject.start()

        let mockSafariCoordinator = MockBaseCoordinator()
        mockCoordinatorBuilder._stubbedSafariCoordinator = mockSafariCoordinator

        let expectedContent = TopicDetailResponse.Content.arrange
        mockViewControllerBuilder._receivedTopicDetailStepByStepAction?([expectedContent])
        mockViewControllerBuilder._receivedStepByStepSelectedAction?(expectedContent)

        #expect(mockSafariCoordinator._startCalled)
    }
}
