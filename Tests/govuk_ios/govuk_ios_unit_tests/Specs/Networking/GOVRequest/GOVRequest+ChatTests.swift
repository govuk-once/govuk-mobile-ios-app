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
}
