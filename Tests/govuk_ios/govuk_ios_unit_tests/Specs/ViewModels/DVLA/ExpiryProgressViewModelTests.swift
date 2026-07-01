import Foundation
import Testing

@testable import govuk_ios

struct ExpiryProgressViewModelTests {
    @Test
    func init_zeroDaysLeft_returnsToday() {
        let sut = ExpiryProgressViewModel(progress: 0.0, daysLeft: 0)
        let result = sut.footer
        #expect(result == String(localized: .DVLA.today))
    }

    @Test
    func init_xDaysLeft_returnsXDaysLeft() {
        let sut = ExpiryProgressViewModel(progress: 0.5, daysLeft: 28)
        let result = sut.footer
        #expect(result == String(localized: .DVLA.daysLeft(days: 28)))
    }

    @Test
    func init_footer_returnsFooter() {
        let sut = ExpiryProgressViewModel(progress: 0.5, daysLeft: 28, footer: "Footer")
        let result = sut.footer
        #expect(result == "Footer")
    }
}
