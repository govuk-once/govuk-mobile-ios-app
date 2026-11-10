import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct AnswerTests {

    @Test(arguments: [
        ("error_timeout", true),
        ("error_non_specific", true),
        ("answered", false),
        ("guardrails_answer", false),
        ("unanswerable_no_govuk_content", false),
        (nil, false)
    ])
    func isTechnicalError_returnsExpectedValue(status: String?,
                                               expected: Bool) {
        let sut = Answer.arrange(status: status)

        #expect(sut.isTechnicalError == expected)
    }

    @Test(arguments: [
        ("12345", true),
        (nil, false)
    ])
    func answerAvailable_returnsExpectedValue(id: String?,
                                              expected: Bool) {
        let sut = Answer.arrange(id: id)

        #expect(sut.answerAvailable == expected)
    }

    @Test
    func source_urlWithFallback_validUrl_returnsUrl() {
        let sut = Source(title: "title", url: "https://www.gov.uk/browse")

        #expect(sut.urlWithFallback.absoluteString == "https://www.gov.uk/browse")
    }

    @Test
    func source_urlWithFallback_invalidUrl_returnsFallback() {
        let sut = Source(title: "title", url: "")

        #expect(sut.urlWithFallback == Constants.API.govukBaseUrl)
    }
}
