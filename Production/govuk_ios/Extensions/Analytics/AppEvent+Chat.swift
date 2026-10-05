import Foundation
import GovKit

extension AppEvent {
    static func chatActionButtonFunction(text: String,
                                         action: String) -> AppEvent {
        buttonFunction(
            text: text,
            section: "Action Menu",
            action: action
        )
    }

    static func chatAskQuestion(type: String = "typed") -> AppEvent {
        .init(
            name: "Chat",
            params: [
                "text": "",
                "type": type,
                "action": "Ask Question"
            ]
        )
    }

    static func chatLinkNavigation(text: String,
                                   url: String) -> AppEvent {
        navigation(
            text: text,
            type: "ChatMarkdownLink",
            external: true,
            additionalParams: [
                "url": url
            ]
        )
    }

    static func chatFeedbackIcon(isPositive: Bool,
                                 questionId: String) -> AppEvent {
        chatFeedback(
            text: isPositive ? "thumbs up" : "thumbs down",
            action: "icon",
            questionId: questionId
        )
    }

    static func chatFeedbackLink(isPositive: Bool,
                                 questionId: String) -> AppEvent {
        chatFeedback(
            text: isPositive ? "Say what went well" : "Say what went wrong",
            action: "link",
            questionId: questionId
        )
    }

    private static func chatFeedback(text: String,
                                     action: String,
                                     questionId: String) -> AppEvent {
        .init(
            name: "ChatFeedback",
            params: [
                "text": text,
                "action": action,
                "type": "Feedback",
                "section": "Chat",
                "questionId": questionId
            ]
        )
    }

    static func chatTermsLinkNavigation(text: String,
                                        url: String) -> AppEvent {
        navigation(
            text: text,
            type: "ChatOnboardingLink",
            external: true,
            additionalParams: [
                "url": url
            ]
        )
    }
}
