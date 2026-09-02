import Foundation

import GovKit

struct ChatExampleQuestionsViewModel {
    let analyticsService: AnalyticsServiceInterface
    let configService: AppConfigServiceInterface

    var exampleQuestions: [ChatExampleQuestion]? {
        guard let questions = configService.chatExampleQuestions else { return nil }

        return questions.map { question in
            ChatExampleQuestion(body: question)
        }
    }

    struct ChatExampleQuestion: Identifiable {
        let id = UUID()
        let body: String
    }
}
