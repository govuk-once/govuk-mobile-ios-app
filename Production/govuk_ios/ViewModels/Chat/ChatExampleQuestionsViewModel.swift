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
            ChatExampleQuestion(body: question)
        }
    }

    struct ChatExampleQuestion: Identifiable {
        let id = UUID()
        let body: String
    }
}
