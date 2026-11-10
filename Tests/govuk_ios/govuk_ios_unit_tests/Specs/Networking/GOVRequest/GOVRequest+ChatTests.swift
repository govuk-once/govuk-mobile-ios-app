import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct GOVRequest_ChatTests {
    @Test
    func askQuestion_conversationId_returnsExpectedValues() {
        let request = GOVRequest.askQuestion(
            "Hello?",
            conversationId: "123"
        )

        #expect(request.urlPath == "/conversation/123")
        #expect(request.method == .put)
    }

    @Test
    func askQuestion_noConversationId_returnsExpectedValues() {
        let request = GOVRequest.askQuestion(
            "Hello?",
            conversationId: nil
        )

        #expect(request.urlPath == "/conversation")
        #expect(request.method == .post)
    }

    @Test(arguments: [
        (true, "positive"),
        (false, "negative")
    ])
    func sendChatFeedback_returnsExpectedValues(isPositive: Bool,
                                                expectedReaction: String) throws {
        let request = GOVRequest.sendChatFeedback(
            conversationId: "123",
            answerId: "456",
            isPositive: isPositive
        )

        #expect(request.urlPath == "/conversation/123/answers/456/feedback")
        #expect(request.method == .post)
        #expect(request.requiresAuthentication)
        #expect(request.additionalHeaders?["Content-Type"] == "application/json")
        let body = try #require(request.body as? ChatFeedbackReaction)
        #expect(body.reaction == expectedReaction)
    }
}
