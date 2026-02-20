import SwiftUI
import GovKit
import GovKitUI

class ChatInfoOnboardingViewModel: InfoViewModelInterface {
    var analyticsService: AnalyticsServiceInterface?
    private let completionAction: () -> Void
    private let cancelOnboardingAction: () -> Void

    init(analyticsService: AnalyticsServiceInterface,
         completionAction: @escaping () -> Void,
         cancelOnboardingAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.completionAction = completionAction
        self.cancelOnboardingAction = cancelOnboardingAction
    }

    var rightBarButtonItem: UIBarButtonItem {
        .cancel(target: self, action: #selector(cancelOnboarding))
    }

    var contentAlignment: Alignment {
        .top
    }

    var visualAssetContent: VisualAssetContent {
        .animation(
            AnimationColorSchemeNames(
                light: "chat_onboarding_one_light",
                dark: "chat_onboarding_one_dark"
            )
        )
    }

    var title: String {
        String.chat.localized("onboardingInfoTitle")
    }

    var subtitle: String {
        String.chat.localized("onboardingInfoDescription")
    }

    var primaryButtonTitle: String {
        String.common.localized("continue")
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.completionAction()
                self?.trackCompletionAction()
            }
        )
    }

    var navBarHidden: Bool {
        false
    }

    var trackingTitle: String {
        title
    }

    var trackingName: String {
        "Chat Onboarding Screen One"
    }

    @objc
    func cancelOnboarding() {
        cancelOnboardingAction()
        trackCancelAction()
    }

    private func trackCancelAction() {
        let event = AppEvent.buttonNavigation(
            text: String.common.localized("cancel"),
            external: false
        )
        analyticsService?.track(event: event)
    }

    private func trackCompletionAction() {
        let event = AppEvent.buttonNavigation(
            text: primaryButtonTitle,
            external: false
        )
        analyticsService?.track(event: event)
    }
}
