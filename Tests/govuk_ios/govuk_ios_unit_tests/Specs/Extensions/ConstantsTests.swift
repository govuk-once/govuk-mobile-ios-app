import Foundation
import Testing

@testable import govuk_ios
@testable import GovKit

struct ConstantsTests {
    @Test
    func defaultSearchUrl_returnsExpectedResult() {
        #expect(Constants.API.defaultSearchUrl.absoluteString == "https://search.service.gov.uk")
    }

    @Test
    func defaultSearchPath_returnsExpectedResult() {
        #expect(Constants.API.defaultSearchPath == "/v0_1/search.json")
    }

    @Test
    func defaultSearchPath_canChange() {
        let originalString = Constants.API.defaultSearchPath

        let expectedPath = UUID().uuidString
        Constants.API.defaultSearchPath = expectedPath
        #expect(Constants.API.defaultSearchPath == expectedPath)

        Constants.API.defaultSearchPath = originalString
    }
}
