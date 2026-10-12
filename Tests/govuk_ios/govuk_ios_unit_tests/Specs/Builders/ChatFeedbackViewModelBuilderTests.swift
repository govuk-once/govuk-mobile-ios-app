import Foundation
import Testing

@testable import govuk_ios

@Suite
struct ChatFeedbackViewModelBuilderTests {

    @Test(arguments: [
        Answer.ratedAnswer,
        .technicalErrorAnswer,
        .arrange(id: nil)
    ])
    func makeViewModel_answerNotEligible_returnsNil(answer: Answer) {
        let sut = makeSUT()

        let result = sut.makeViewModel(
            questionId: "questionId",
            conversationId: "conversationId",
            answer: answer,
            onConfirmed: { },
            onError: { _ in }
        )

        #expect(result == nil)
    }

    @Test(arguments: [true, false])
    func makeViewModel_rating_sendsFeedbackForAnswer(isPositive: Bool) throws {
        let mockChatService = MockChatService()
        let sut = makeSUT(chatService: mockChatService)
        let result = try #require(
            sut.makeViewModel(
                questionId: "questionId",
                conversationId: "conversationId",
                answer: .arrange(id: "answerId"),
                onConfirmed: { },
                onError: { _ in }
            )
        )

        result.rate(isPositive: isPositive)

        try #require(mockChatService._receivedSendFeedbackCalls.count == 1)
        let call = mockChatService._receivedSendFeedbackCalls[0]
        #expect(call.conversationId == "conversationId")
        #expect(call.answerId == "answerId")
        #expect(call.isPositive == isPositive)
    }

    @Test(arguments: [
        ChatError.authenticationError,
        .apiUnavailable,
        .networkUnavailable,
        .pageNotFound,
        .validationError
    ])
    func makeViewModel_ratingFails_reportsErrorAndStaysUnrated(error: ChatError) throws {
        let mockChatService = MockChatService()
        mockChatService._stubbedSendFeedbackResult = .failure(error)
        let sut = makeSUT(chatService: mockChatService)
        var receivedErrors: [ChatError] = []
        let result = try #require(
            sut.makeViewModel(
                questionId: "questionId",
                conversationId: "conversationId",
                answer: .answeredAnswer,
                onConfirmed: { },
                onError: { receivedErrors.append($0) }
            )
        )

        result.rate(isPositive: true)

        #expect(receivedErrors == [error])
        #expect(result.state == .unrated)
    }

    @Test
    func makeViewModel_ratingSucceeds_showsRatingAndReportsNoError() throws {
        let sut = makeSUT()
        var receivedErrors: [ChatError] = []
        let result = try #require(
            sut.makeViewModel(
                questionId: "questionId",
                conversationId: "conversationId",
                answer: .answeredAnswer,
                onConfirmed: { },
                onError: { receivedErrors.append($0) }
            )
        )

        result.rate(isPositive: true)

        #expect(receivedErrors.isEmpty)
        #expect(result.state == .rated(isPositive: true))
    }

    @Test
    func makeViewModel_confirmed_callsOnConfirmed() throws {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = .denied
        let sut = makeSUT(analyticsService: mockAnalyticsService)
        var didConfirm = false
        let result = try #require(
            sut.makeViewModel(
                questionId: "questionId",
                conversationId: "conversationId",
                answer: .answeredAnswer,
                onConfirmed: { didConfirm = true },
                onError: { _ in }
            )
        )

        result.rate(isPositive: true)

        #expect(didConfirm)
    }

    private func makeSUT(
        chatService: MockChatService = MockChatService(),
        analyticsService: MockAnalyticsService = MockAnalyticsService()
    ) -> ChatFeedbackViewModelBuilder {
        ChatFeedbackViewModelBuilder(
            chatService: chatService,
            analyticsService: analyticsService,
            scheduleConfirmation: { _ in }
        )
    }
}
