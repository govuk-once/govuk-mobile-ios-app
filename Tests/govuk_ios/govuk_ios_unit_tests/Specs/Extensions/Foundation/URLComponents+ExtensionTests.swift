import Foundation
import Testing

@testable import govuk_ios

@Suite
struct URLComponents_ExtensionsTests {
    @Test
    func caseInsensitiveQueryParam_present_returnsValue() {
        let sut = URLComponents(string: "https://www.gov.uk?Test_Key=True")!
        #expect(sut.caseInsensitiveQueryParam(for: "test_key") == "true")
    }

    @Test
    func caseInsensitiveQueryParam_absent_returnsNil() {
        let sut = URLComponents(string: "https://www.gov.uk")!
        #expect(sut.caseInsensitiveQueryParam(for: "test_key") == nil)
    }
}
