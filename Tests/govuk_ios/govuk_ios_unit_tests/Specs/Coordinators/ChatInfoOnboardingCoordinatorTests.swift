import Foundation
import UIKit
import GovKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ChatInfoOnboardingCoordinatorTests {
    @Test
    func start_setsChatInfoOnboardingViewController() throws {
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let expectedViewController = UIViewController()
        mockViewControllerBuilder._stubbedChatInfoOnboardingController = expectedViewController
        let navigationController = UINavigationController()
        let sut = ChatInfoOnboardingCoordinator(
            navigationController: navigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            cancelOnboardingAction: { },
            setChatViewControllerAction: { animated in }
        )

        sut.start()
        let firstViewController = navigationController.viewControllers.first
        #expect(firstViewController == expectedViewController)
    }

    @Test
    func infoCancelAction_callsRootDismiss() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockNavigationController = MockNavigationController()
        let sut = ChatInfoOnboardingCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: MockCoordinatorBuilder(container: .init()),
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            cancelOnboardingAction: {},
            setChatViewControllerAction: { _ in }
        )
        sut.start()
        mockViewControllerBuilder._receivedChatInfoOnboardingCancelAction?()
        #expect(mockNavigationController._dismissCalled == true)
    }

    @Test
    func consentCancelAction_callsRootDismiss() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockNavigationController = MockNavigationController()
        let sut = ChatInfoOnboardingCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            cancelOnboardingAction: {},
            setChatViewControllerAction: { _ in }
        )
        sut.start()
        mockViewControllerBuilder._receivedChatInfoOnboardingCompletionAction?()
        mockCoordinatorBuilder._receivedChatConsentCancelAction?()
        #expect(mockNavigationController._dismissCalled == true)
    }

    @Test
    func consentCompletionAction_callsRootDismiss() {
        let mockViewControllerBuilder = MockViewControllerBuilder()
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockNavigationController = MockNavigationController()
        let sut = ChatInfoOnboardingCoordinator(
            navigationController: mockNavigationController,
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: mockViewControllerBuilder,
            analyticsService: MockAnalyticsService(),
            cancelOnboardingAction: {},
            setChatViewControllerAction: { _ in }
        )
        sut.start()
        mockViewControllerBuilder._receivedChatInfoOnboardingCompletionAction?()
        mockCoordinatorBuilder._receivedChatConsentOnboardingCompletion?()
        #expect(mockNavigationController._dismissCalled == true)
    }
}
