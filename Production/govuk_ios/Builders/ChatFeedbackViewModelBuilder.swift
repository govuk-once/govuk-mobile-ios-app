import Foundation
import GovKit

struct ChatFeedbackViewModelBuilder {
    private let chatService: ChatServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let scheduleConfirmation: ChatFeedbackViewModel.ConfirmationScheduler

    init(chatService: ChatServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         scheduleConfirmation: @escaping ChatFeedbackViewModel.ConfirmationScheduler) {
        self.chatService = chatService
        self.analyticsService = analyticsService
        self.scheduleConfirmation = scheduleConfirmation
    }

    func makeViewModel(questionId: String,
                       conversationId: String,
                       answer: Answer,
                       confirmedAction: @escaping () -> Void,
                       errorAction: @escaping (ChatError) -> Void) -> ChatFeedbackViewModel? {
        guard let answerId = answer.id,
              answer.feedback == nil,
              !answer.isTechnicalError
        else { return nil }
        return ChatFeedbackViewModel(
            questionId: questionId,
            analyticsService: analyticsService,
            scheduleConfirmation: scheduleConfirmation,
            notificationCenter: .default,
            sendRating: { isPositive, completion in
                chatService.sendFeedback(
                    conversationId: conversationId,
                    answerId: answerId,
                    isPositive: isPositive,
                    completion: { result in
                        let error = result.getError()
                        completion(error == nil)
                        if let error {
                            errorAction(error)
                        }
                    }
                )
            },
            confirmedAction: confirmedAction
        )
    }
}
