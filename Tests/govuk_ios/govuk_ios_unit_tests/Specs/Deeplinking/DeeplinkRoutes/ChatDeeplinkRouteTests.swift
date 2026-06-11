import Foundation
import UIKit
import Testing

@testable import govuk_ios

@Suite
@MainActor
struct ChatDeeplinkRouteTests {
    @Test
    func pattern_returnsExpectedValue() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder.mock
        let subject = ChatDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        #expect(subject.pattern == "/chat")
    }

    @Test
    func action_isInvokable() {
        let mockCoordinatorBuilder = MockCoordinatorBuilder(container: .init())
        let mockChatCoordinator = MockChatCoordinator(
            navigationController: UINavigationController(),
            coordinatorBuilder: mockCoordinatorBuilder,
            viewControllerBuilder: MockViewControllerBuilder(),
            deepLinkStore: DeeplinkDataStore(routes: [], root: UIViewController()),
            analyticsService: MockAnalyticsService(),
            chatService: MockChatService(),
            authenticationService: MockAuthenticationService(),
            cancelOnboardingAction: { }
        )
        
        let subject = ChatDeeplinkRoute(coordinatorBuilder: mockCoordinatorBuilder)

        subject.action(parent: mockChatCoordinator, params: [:])
        #expect(mockChatCoordinator._stubbedDidShowOnboarding)
    }
}
