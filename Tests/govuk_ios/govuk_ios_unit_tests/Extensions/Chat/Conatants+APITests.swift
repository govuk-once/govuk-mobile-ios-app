import Foundation
import Testing

@testable import GovKit

@Suite
@MainActor
struct Conatants_APITests {
    @Test
    func defaultChatPrivacyPolicyUrl_returnsExpectedResult() {
        #expect(Constants.API.defaultChatPrivacyPolicyUrl.absoluteString == "https://www.gov.uk/government/publications/govuk-chat-privacy-notice")
    }

    @Test
    func defaultChatTermsUrl_returnsExpectedResult() {
        #expect(Constants.API.defaultChatTermsUrl.absoluteString == "https://www.gov.uk/guidance/govuk-chat-terms-and-conditions")
    }
    @Test
    func defaultChatAboutUrl_returnsExpectedResult() {
        #expect(Constants.API.defaultChatAboutUrl.absoluteString == "https://www.gov.uk/guidance/about-govuk-chat")
    }

    @Test
    func defaultChatFeedbackUrl_returnsExpectedResult() {
        #expect(Constants.API.defaultChatFeedbackUrl.absoluteString == "https://surveys.publishing.service.gov.uk/s/SUIEH2/")
    }
}
