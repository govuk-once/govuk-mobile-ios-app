import Foundation

@testable import govuk_ios

final class ChatTermsOnboardingViewControllerSnapshotTests: SnapshotTestCase {
    let viewControllerBuilder = ViewControllerBuilder()

    func test_loadInNavigationController_light_rendersCorrectly() {
        let chatTermsOnboardingViewController = viewControllerBuilder.chatTermsOnboarding(
            analyticsService: MockAnalyticsService(),
            chatService: MockChatService(),
            cancelOnboardingAction: { },
            completionAction: { },
            openURLAction: { _ in }
        )

        VerifySnapshotInNavigationController(
            viewController: chatTermsOnboardingViewController,
            mode: .light)
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let chatTermsOnboardingViewController = viewControllerBuilder.chatTermsOnboarding(
            analyticsService: MockAnalyticsService(),
            chatService: MockChatService(),
            cancelOnboardingAction: { },
            completionAction: { },
            openURLAction: { _ in }
        )

        VerifySnapshotInNavigationController(
            viewController: chatTermsOnboardingViewController,
            mode: .dark
        )
    }
}

