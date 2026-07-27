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
    func searchPath_returnsExpectedResult() {
        #expect(Constants.API.searchPath == "/v0_1/search.json")
    }

    @Test
    func searchPath_canChange() {
        let originalString = Constants.API.searchPath

        let expectedPath = UUID().uuidString
        Constants.API.searchPath = expectedPath
        #expect(Constants.API.searchPath == expectedPath)

        Constants.API.searchPath = originalString
    }
}
