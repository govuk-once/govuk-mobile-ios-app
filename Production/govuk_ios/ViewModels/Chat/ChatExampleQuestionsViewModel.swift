import Foundation

import GovKit

struct ChatExampleQuestionsViewModel {
    private let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface

    init(
        analyticsService: AnalyticsServiceInterface,
        configService: AppConfigServiceInterface
    ) {
        self.analyticsService = analyticsService
        self.configService = configService
    }

    var exampleQuestions: [ChatExampleQuestion] {
        guard let exampleQuestions = configService.chatExampleQuestions
        else { return [] }

        return exampleQuestions.map { question in
            ChatExampleQuestion(
                body: question,
                accessibilityLabel: "\(String(localized: .Chat.exampleQuestionsTitle)) " + question
            )
        }
    }

    func trackEcommerce() {
        let event = AppEvent.viewItemList(
            name: "chat suggestions",
            id: "chat suggestions",
            items: exampleQuestions.enumerated().map { index, question in
                ChatExampleQuestionItem(
                    name: question.body,
                    listId: "chat_suggestion",
                    index: index + 1
                )
            }
        )
        analyticsService.track(event: event)
    }

    func trackExampleQuestionSelected(
        text: String,
        index: Int
    ) {
        let event = AppEvent.function(
            text: text,
            type: "suggestion",
            section: "Chat",
            action: "Tapped"
        )
        analyticsService.track(event: event)
        trackEcommerceItemSelected(
            text: text,
            index: index
        )
    }

    private func trackEcommerceItemSelected(
        text: String,
        index: Int
    ) {
        let listName = "chat suggestions"
        let event = AppEvent.selectItem(
            listName: listName,
            listId: listName,
            results: exampleQuestions.count,
            items: [
                ChatExampleQuestionItem(
                    name: text,
                    listId: listName,
                    index: index
                )
            ]
        )
        analyticsService.track(event: event)
    }

    struct ChatExampleQuestion {
        var body: String
        let accessibilityLabel: String
    }
}
