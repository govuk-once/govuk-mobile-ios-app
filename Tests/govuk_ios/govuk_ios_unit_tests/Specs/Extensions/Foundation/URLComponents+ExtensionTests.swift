import Foundation
import Testing

@testable import govuk_ios

@Suite
struct URLComponents_ExtensionsTests {
    @Test
    func lowercaseQueryParamValue_present_returnsValue() {
        let sut = URLComponents(string: "https://www.gov.uk?test_key=True")!
        #expect(sut.lowercaseQueryParamValue(for: "test_key") == "true")
    }

    @Test
    func lowercaseQueryParamValue_absent_returnsNil() {
        let sut = URLComponents(string: "https://www.gov.uk")!
        #expect(sut.lowercaseQueryParamValue(for: "test_key") == nil)
    }
}
