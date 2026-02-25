import SwiftUI
import GovKit
import GovKitUI

final class ChatTermsOnboardingViewModel: InfoViewModelInterface {
    var analyticsService: (any GovKit.AnalyticsServiceInterface)?
    private var chatService: ChatServiceInterface
    private let cancelOnboardingAction: () -> Void
    private let completionAction: () -> Void

    init(analyticsService: AnalyticsServiceInterface,
         chatService: ChatServiceInterface,
         cancelOnboardingAction: @escaping () -> Void,
         completionAction: @escaping () -> Void) {
        self.analyticsService = analyticsService
        self.chatService = chatService
        self.cancelOnboardingAction = cancelOnboardingAction
        self.completionAction = completionAction
    }

    var title: String {
        String(localized: .Chat.onboardingTermsTitle)
    }

    var markdownText: String {
        String(
            localized: .Chat.onboardingTermsSubtitle(
                chatService.privacyPolicy.absoluteString
            )
        )
    }

    var primaryButtonTitle: String {
        String(localized: .Chat.onboardingTermsPrimaryButtonTitle)
    }

    var primaryButtonViewModel: GOVUKButton.ButtonViewModel {
        return .init(
            localisedTitle: primaryButtonTitle,
            action: { [weak self] in
                self?.primaryButtonAction()
            }
        )
    }

    var secondaryButtonTitle: String {
        String(localized: .Chat.onboardingTermsSecondaryButtonTitle)
    }

    var secondaryButtonViewModel: GOVUKButton.ButtonViewModel? {
        return .init(
            localisedTitle: secondaryButtonTitle,
            action: { [weak self] in
                self?.secondaryButtonAction()
            }
        )
    }

    var visualAssetContent: VisualAssetContent {
        .animation(
            AnimationColorSchemeNames(
                light: "chat_onboarding_three_light",
                dark: "chat_onboarding_three_dark"
            )
        )
    }

    var trackingTitle: String {
        title
    }

    var trackingName: String {
        "Chat Onboarding Screen Three"
    }

    var navBarHidden: Bool {
        false
    }

    private func primaryButtonAction() {
        chatService.chatOnboardingSeen = true
        completionAction()
        trackCompletionAction()
    }

    private func secondaryButtonAction() {
        cancelOnboardingAction()
        trackCancelAction()
    }

    private func trackCancelAction() {
        let event = AppEvent.buttonNavigation(
            text: secondaryButtonTitle,
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
