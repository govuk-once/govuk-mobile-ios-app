import Foundation

import GovKit

struct ChatExampleQuestionsViewModel {
    let analyticsService: AnalyticsServiceInterface
    let configService: AppConfigServiceInterface

    var exampleQuestions: [ChatExampleQuestion]? {
        configService.chatExampleQuestions?.map { question in
            ChatExampleQuestion(body: question)
        }
    }

    struct ChatExampleQuestion: Identifiable {
        let id = UUID()
        let body: String
    }
}
