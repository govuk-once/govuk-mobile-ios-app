import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ChatConsentOnboardingCoordinatorTests {
    @Test
    func start_setsChatConsentOnboardingViewController() throws {
        let mockChatService = MockChatService()
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatConsentOnboardingController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ChatConsentOnboardingCoordinator(
            navigationController: navigationController,
            viewControllerBuilder: mockViewControllerBuilder,
            coordinatorBuilder: mockCoordinatorBuilder,
            analyticsService: MockAnalyticsService(),
            chatService: mockChatService,
            cancelOnboardingAction: { },
            completionAction: { }
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }
}
