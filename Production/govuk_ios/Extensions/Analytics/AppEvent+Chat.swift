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
        let text = isPositive ? "thumbs up" : "thumbs down"
        return .init(
            name: "Function",
            params: [
                "text": text,
                "type": "feedback",
                "section": "Chat",
                "action": text,
                "question_id": questionId
            ]
        )
    }

    static func chatFeedbackLink(isPositive: Bool,
                                 questionId: String) -> AppEvent {
        navigation(
            text: isPositive ? "Say what went well" : "Say what went wrong",
            type: "feedback",
            external: false,
            additionalParams: [
                "section": "Chat",
                "question_id": questionId
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
