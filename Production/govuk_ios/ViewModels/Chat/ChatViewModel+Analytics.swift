import Foundation
import GovKit

extension ChatViewModel {
    func openAboutURL() {
        trackMenuTap(String.chat.localized("aboutMenuTitle"))
        openURLAction(chatService.about)
    }

    func openPrivacyURL() {
        trackMenuTap(String.chat.localized("privacyMenuTitle"))
        openURLAction(chatService.privacyPolicy)
    }

    func openFeedbackURL() {
        trackMenuTap(String.chat.localized("feedbackMenuTitle"))
        openURLAction(chatService.feedback)
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func trackMenuClearChatTap() {
        let event = AppEvent.chatActionButtonFunction(
            text: String.chat.localized("clearMenuTitle"),
            action: "Clear Chat Tapped"
        )
        analyticsService.track(event: event)
    }

    func trackMenuClearChatConfirmTap() {
        let event = AppEvent.chatActionButtonFunction(
            text: String.chat.localized("clearAlertConfirmTitle"),
            action: "Clear Chat Yes Tapped"
        )
        analyticsService.track(event: event)
    }

    func trackMenuClearChatDenyTap() {
        let event = AppEvent.chatActionButtonFunction(
            text: String.chat.localized("clearAlertDenyTitle"),
            action: "Clear Chat No Tapped"
        )
        analyticsService.track(event: event)
    }

    func trackAskQuestionSubmission(type: String) {
        let event = AppEvent.chatAskQuestion(type: type)
        analyticsService.track(event: event)
    }

    func trackAnswerResponse() {
        let event = AppEvent.function(
            text: "Chat Question Answer Returned",
            type: "ChatQuestionAnswerReturned",
            section: "Chat",
            action: "Chat Question Answer Returned"
        )
        analyticsService.track(event: event)
    }

    private func trackMenuTap(_ itemTitle: String) {
        let event = AppEvent.buttonNavigation(
            text: itemTitle,
            external: true
        )
        analyticsService.track(event: event)
    }
}
