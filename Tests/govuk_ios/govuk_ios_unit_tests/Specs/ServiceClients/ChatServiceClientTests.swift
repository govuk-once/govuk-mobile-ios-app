import Foundation
import Testing
import FactoryKit

@testable import govuk_ios

@Suite
struct ChatServiceClientTests {

    @Test
    func askQuestion_newConversation_sendsExpectedRequest() throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        let expectedQuestion = "expected question?"

        sut.askQuestion(expectedQuestion,
                        conversationId: nil,
                        completion: { _ in } )

        #expect(mockAPI._receivedSendRequest?.urlPath == "/conversation")
        #expect(mockAPI._receivedSendRequest?.method == .post)
        let body = try #require(mockAPI._receivedSendRequest?.body as? Question)
        #expect(body.userQuestion == expectedQuestion)
    }

    @Test
    func askQuestion_existingConversation_sendsExpectedRequest() throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        let expectedQuestion = "expected question?"
        let expectedConversationId = "conversationId"

        sut.askQuestion(expectedQuestion,
                        conversationId: expectedConversationId,
                        completion: { _ in } )

        #expect(mockAPI._receivedSendRequest?.urlPath == "/conversation/\(expectedConversationId)")
        #expect(mockAPI._receivedSendRequest?.method == .put)
        let body = try #require(mockAPI._receivedSendRequest?.body as? Question)
        #expect(body.userQuestion == expectedQuestion)
    }

    @Test
    func askQuestion_returnsExpectedResult() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        let expectedQuestion = "expected question?"
        mockAPI._stubbedSendResponse = .success(Self.startConversationResponse)

        let chatResponseResult = await withCheckedContinuation { continuation in
            sut.askQuestion(
                expectedQuestion,
                conversationId: nil,
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }
        let chatResponse = try #require(try? chatResponseResult.get())
        #expect(chatResponse.id == "96d009be-6b32-4192-bef8-aeecb6a0e11c")
    }

    @Test
    func fetchHistory_sendsExpectedRequest() {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        let expectedConversationId = "expected_conversation_id"

        sut.fetchHistory(conversationId: expectedConversationId,
                         completion: { _ in } )
        #expect(mockAPI._receivedSendRequest?.urlPath == "/conversation/\(expectedConversationId)")
        #expect(mockAPI._receivedSendRequest?.method == .get)
    }

    @Test
    func fetchHistory_returnsExpectedResult() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .success(Self.historyResponse)

        let chatHistoryResult = await withCheckedContinuation { continuation in
            sut.fetchHistory(
                conversationId: "conversationId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }
        let chatHistory = try #require(try? chatHistoryResult.get())
        #expect(chatHistory.id == "916615e3-7f2f-4443-a858-c7b6a17af3d1")
        #expect(chatHistory.answeredQuestions.count == 1)
        #expect(chatHistory.answeredQuestions.first?.id == "dcf7cd50-dd8f-4d5d-9704-6d6d6b0a3ce1")
        #expect(chatHistory.answeredQuestions.first?.answer.sources?.count == 2)
        #expect(chatHistory.pendingQuestion?.id == "79f327b6-feb3-4cde-ba26-1ffc3fa832b6")
    }

    @Test
    func fetchAnswer_returnsExpectedResult() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .success(Self.answerResponse)

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try #require(try? fetchAnswerResult.get())
        #expect(answer.id == "ea03f79b-2fe1-4f80-8796-b8b9a0508322")
        #expect(answer.sources?.count == 1)
    }

    @Test
    func fetchAnswer_pending_returnsExpectedResult() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .success(Self.emptyAnswerResponse)

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try #require(try? fetchAnswerResult.get())
        #expect(answer.id == nil)
        #expect (fetchAnswerResult.getError() == nil)
    }

    @Test
    func askQuestion_validationError_returnsExpectedError() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .failure(ChatError.validationError)

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try? fetchAnswerResult.get()
        let error = fetchAnswerResult.getError()
        #expect(answer?.id == nil)
        #expect (error == .validationError)
    }

    @Test
    func tokenRefreshError_returnsExpectedError() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .failure(TokenRefreshError.tokenResponseError)

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try? fetchAnswerResult.get()
        let error = fetchAnswerResult.getError()
        #expect(answer?.id == nil)
        #expect (error == .authenticationError)
    }

    @Test
    func networkUnavailable_returnsExpectedError() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .failure(NSError(domain: "GOVUKApp", code: NSURLErrorNotConnectedToInternet))

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try? fetchAnswerResult.get()
        let error = fetchAnswerResult.getError()
        #expect(answer?.id == nil)
        #expect (error == .networkUnavailable)
    }

    @Test
    func unknownError_returnsApiUnavailableError() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .failure(NSError(domain: "GOVUKApp", code: 12345))

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try? fetchAnswerResult.get()
        let error = fetchAnswerResult.getError()
        #expect(answer?.id == nil)
        #expect (error == .apiUnavailable)

    }

    @Test
    func sendFeedback_sendsExpectedRequest() throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)

        sut.sendFeedback(conversationId: "conversationId",
                         answerId: "answerId",
                         isPositive: false,
                         completion: { _ in })

        #expect(
            mockAPI._receivedSendRequest?.urlPath ==
            "/conversation/conversationId/answers/answerId/feedback"
        )
        #expect(mockAPI._receivedSendRequest?.method == .post)
        let body = try #require(mockAPI._receivedSendRequest?.body as? ChatFeedbackReaction)
        #expect(body.reaction == "negative")
    }

    @Test
    func sendFeedback_emptyResponse_returnsSuccess() async {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .success(Data())

        let result = await withCheckedContinuation { continuation in
            sut.sendFeedback(
                conversationId: "conversationId",
                answerId: "answerId",
                isPositive: true,
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        #expect(result.getError() == nil)
    }

    @Test(arguments: zip(
        [ChatError.feedbackAlreadyGiven as Error,
         TokenRefreshError.tokenResponseError,
         NSError(domain: "GOVUKApp", code: NSURLErrorNotConnectedToInternet),
         NSError(domain: "GOVUKApp", code: 12345)],
        [ChatError.feedbackAlreadyGiven,
         .authenticationError,
         .networkUnavailable,
         .apiUnavailable]
    ))
    func sendFeedback_failure_returnsExpectedError(error: Error,
                                                   expectedError: ChatError) async {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .failure(error)

        let result = await withCheckedContinuation { continuation in
            sut.sendFeedback(
                conversationId: "conversationId",
                answerId: "answerId",
                isPositive: true,
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        #expect(result.getError() == expectedError)
    }

    @Test
    func fetchHistory_ratedAnswer_decodesFeedbackAndStatus() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .success(Self.ratedHistoryResponse)

        let chatHistoryResult = await withCheckedContinuation { continuation in
            sut.fetchHistory(
                conversationId: "conversationId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let chatHistory = try #require(try? chatHistoryResult.get())
        let answer = try #require(chatHistory.answeredQuestions.first?.answer)
        #expect(answer.status == "error_timeout")
        #expect(answer.isTechnicalError)
        #expect(answer.feedback?.reaction == "negative")
        #expect(answer.feedback?.createdAt == "2025-06-05T11:39:00+01:00")
    }

    @Test
    func fetchAnswer_unratedAnswer_hasNoFeedback() async throws {
        let mockAPI = MockAPIServiceClient()
        let sut = ChatServiceClient(serviceClient: mockAPI)
        mockAPI._stubbedSendResponse = .success(Self.answerResponse)

        let fetchAnswerResult = await withCheckedContinuation { continuation in
            sut.fetchAnswer(
                conversationId: "conversationId",
                questionId: "questionId",
                completion: {
                    continuation.resume(returning: $0)
                }
            )
        }

        let answer = try #require(try? fetchAnswerResult.get())
        #expect(answer.status == "answered")
        #expect(!answer.isTechnicalError)
        #expect(answer.feedback == nil)
    }
}

private extension ChatServiceClientTests {
    static let startConversationResponse: Data =
    """
    {
      "id": "96d009be-6b32-4192-bef8-aeecb6a0e11c",
      "answer_url": "https://chat.integration.publishing.service.gov.uk/api/v0/conversation/a3371dbf-64ad-4d98-a6c4-25fde59f2886/questions/96d009be-6b32-4192-bef8-aeecb6a0e11c/answer",
      "conversation_id": "a3371dbf-64ad-4d98-a6c4-25fde59f2886",
      "created_at": "2025-06-04T13:58:34+01:00",
      "message": "expected question?"
    }
    """.data(using: .utf8)!

    static let historyResponse: Data =
    """
    {
      "id": "916615e3-7f2f-4443-a858-c7b6a17af3d1",
      "answered_questions": [
        {
          "id": "dcf7cd50-dd8f-4d5d-9704-6d6d6b0a3ce1",
          "answer": {
            "id": "a5e5262e-be0b-4508-836d-9375cc29f127",
            "created_at": "2025-06-05T11:38:09+01:00",
            "message": "To register as a pig keeper...",
            "sources": [
              {
                "url": "https://www.integration.publishing.service.gov.uk/guidance/keeping-a-pet-pig-or-micropig",
                "title": "Keeping a pet pig or 'micropig'"
              },
              {
                "url": "https://www.integration.publishing.service.gov.uk/guidance/moving-pigs-what-keepers-need-to-know#before-you-start-keeping-pigs",
                "title": "Moving pigs: what keepers need to know: Before you start keeping pigs"
              }
            ]
          },
          "conversation_id": "916615e3-7f2f-4443-a858-c7b6a17af3d1",
          "created_at": "2025-06-05T11:37:56+01:00",
          "message": "How do I register as a pig keeper?"
        }
      ],
      "created_at": "2025-06-05T09:39:44+01:00",
      "pending_question": {
          "id": "79f327b6-feb3-4cde-ba26-1ffc3fa832b6",
          "answer_url": "https://chat.integration.publishing.service.gov.uk/api/v0/conversation/aff33dd1-868b-4587-a712-922e11a6ca12/questions/79f327b6-feb3-4cde-ba26-1ffc3fa832b6/answer",
          "conversation_id": "aff33dd1-868b-4587-a712-922e11a6ca12",
          "created_at": "2025-06-05T11:41:59+01:00",
          "message": "How do I apply for a drivers license"
      }
    }
    """.data(using: .utf8)!

    static let answerResponse: Data =
    """
    {
      "id": "ea03f79b-2fe1-4f80-8796-b8b9a0508322",
      "created_at": "2025-06-05T11:42:09+01:00",
      "message": "To apply for your first provisional driving licence, you can do so\\nonline",
      "status": "answered",
      "feedback_url": "/api/v1/conversation/aff33dd1-868b-4587-a712-922e11a6ca12/answers/ea03f79b-2fe1-4f80-8796-b8b9a0508322/feedback",
      "sources": [
        {
          "url": "https://www.integration.publishing.service.gov.uk/apply-first-provisional-driving-licence",
          "title": "Apply for your first provisional driving licence"
        }
      ]
    }
    """.data(using: .utf8)!

    static let ratedHistoryResponse: Data =
    """
    {
      "id": "916615e3-7f2f-4443-a858-c7b6a17af3d1",
      "answered_questions": [
        {
          "id": "dcf7cd50-dd8f-4d5d-9704-6d6d6b0a3ce1",
          "answer": {
            "id": "a5e5262e-be0b-4508-836d-9375cc29f127",
            "created_at": "2025-06-05T11:38:09+01:00",
            "message": "Sorry, there is a problem.",
            "status": "error_timeout",
            "sources": [],
            "feedback": {
              "reaction": "negative",
              "created_at": "2025-06-05T11:39:00+01:00"
            }
          },
          "conversation_id": "916615e3-7f2f-4443-a858-c7b6a17af3d1",
          "created_at": "2025-06-05T11:37:56+01:00",
          "message": "How do I register as a pig keeper?"
        }
      ],
      "created_at": "2025-06-05T09:39:44+01:00"
    }
    """.data(using: .utf8)!

    static let emptyAnswerResponse: Data =
    """
    {}
    """.data(using: .utf8)!
}
