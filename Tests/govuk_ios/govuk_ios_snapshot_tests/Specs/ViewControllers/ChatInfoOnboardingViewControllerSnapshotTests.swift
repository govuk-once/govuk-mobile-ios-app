import Foundation

@testable import govuk_ios

final class ChatInfoOnboardingViewControllerSnapshotTests: SnapshotTestCase {
    let viewControllerBuilder = ViewControllerBuilder()

    func test_loadInNavigationController_light_rendersCorrectly() {
        let chatInfoOnboardingViewController = viewControllerBuilder.chatInfoOnboarding(
            analyticsService: MockAnalyticsService(),
            completionAction: { },
            cancelOnboardingAction: { }
        )

        VerifySnapshotInNavigationController(
            viewController: chatInfoOnboardingViewController,
            mode: .light
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        let chatInfoOnboardingViewController = viewControllerBuilder.chatInfoOnboarding(
            analyticsService: MockAnalyticsService(),
            completionAction: { },
            cancelOnboardingAction: { }
        )

        VerifySnapshotInNavigationController(
            viewController: chatInfoOnboardingViewController,
            mode: .dark
        )
    }
}
