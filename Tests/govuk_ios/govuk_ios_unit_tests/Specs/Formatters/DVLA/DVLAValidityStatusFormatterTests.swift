import Foundation
import Testing

@testable import govuk_ios

@Suite
struct DVLAValidityStatusFormatterTests {
    @Test
    func formatStatus_validDate_returnsExpectedString() {
        let sut = DVLAValidityStatusFormatter()
        let result = sut.formatStatus(from: .arrange("03/06/2026"))
        #expect(result == "Valid until 3 June 2026")
    }

    @Test
    func formatStatus_dateIsNil_returnsUnknown() {
        let sut = DVLAValidityStatusFormatter()
        let result = sut.formatStatus(from: nil)
        #expect(result == String.dvla.localized("Unknown"))
    }
}
