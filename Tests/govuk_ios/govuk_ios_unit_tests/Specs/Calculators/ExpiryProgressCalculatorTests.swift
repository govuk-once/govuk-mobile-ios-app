import Foundation
import Testing

@testable import govuk_ios

@Suite
struct ExpiryProgressCalculatorTests {
    private let mockCurrentDate = Date.arrange("01/06/2026")

    @Test
    func calculate_expiryDateIsInsideCountdownWindow_returnsExpectedResult() {
        let expiryDate = Date.arrange("29/06/2026")
        // 28 days from current date
        let sut = ExpiryProgressCalculator(countdownWindowDays: 56)
        let result = sut.calculate(
            expiryDate: expiryDate,
            currentDate: mockCurrentDate
        )
        #expect(result.daysLeft == 28)
        #expect(result.progress == 0.5)
        #expect(result.isWithinCountdownWindow == true)
    }

    @Test
    func calculate_expiryDateIsOnCountdownWindowEdge_returnsExpectedResult() {
        let expiryDate = Date.arrange("27/07/2026")
        // 56 days from current date
        let sut = ExpiryProgressCalculator(countdownWindowDays: 56)
        let result = sut.calculate(
            expiryDate: expiryDate,
            currentDate: mockCurrentDate
        )
        #expect(result.daysLeft == 56)
        #expect(result.progress == 1.0)
        #expect(result.isWithinCountdownWindow == true)
    }

    @Test
    func calculate_expiryDateIsOutsideCountdownWindow_returnsExpectedResult() {
        let expiryDate = Date.arrange("31/07/2026")
        // 60 days from current date
        let sut = ExpiryProgressCalculator(countdownWindowDays: 56)
        let result = sut.calculate(
            expiryDate: expiryDate,
            currentDate: mockCurrentDate
        )
        #expect(result.daysLeft == 60)
        #expect(result.progress == 1.0)
        #expect(result.isWithinCountdownWindow == false)
    }

    @Test
    func calculate_expiryDateIsToday_returnsExpectedResult() {
        let expiryDate = Date.arrange("01/06/2026")
        // 0 days from current date
        let sut = ExpiryProgressCalculator(countdownWindowDays: 56)
        let result = sut.calculate(
            expiryDate: expiryDate,
            currentDate: mockCurrentDate
        )
        #expect(result.daysLeft == 0)
        #expect(result.progress == 0.0)
        #expect(result.isWithinCountdownWindow == true)
    }

    @Test
    func calculate_expiryDateIsInPast_returnsExpectedResult() {
        let expiryDate = Date.arrange("31/05/2026")
        // -1 days from current date
        let sut = ExpiryProgressCalculator(countdownWindowDays: 56)
        let result = sut.calculate(
            expiryDate: expiryDate,
            currentDate: mockCurrentDate
        )
        #expect(result.daysLeft == 0)
        #expect(result.progress == 0.0)
        #expect(result.isWithinCountdownWindow == true)
    }
}
