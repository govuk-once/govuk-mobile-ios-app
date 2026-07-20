import Foundation
import Testing

struct Date_ExtensionsTest {

    // Tuesday, 7 July 2026 at 10:45:00 UTC+1
    private let referenceDate = Date(timeIntervalSince1970: 1783417500)

    // MARK: - formatMessageListDate

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "Europe/London")
        return Calendar.current.date(from: components)!
    }


    @Test
    func messageList_today_showsTodayWithTime() {
        #expect(referenceDate.formatMessageListDate(now: referenceDate) == "Today, 10:45am")
    }

    @Test
    func messageList_todayPM_showsTodayWithPMTime() {
        let date = makeDate(year: 2026, month: 7, day: 7, hour: 21, minute: 30)
        #expect(date.formatMessageListDate(now: referenceDate) == "Today, 9:30pm")
    }

    @Test
    func messageList_yesterday_showsYesterday() {
        let date = makeDate(year: 2026, month: 7, day: 6)
        #expect(date.formatMessageListDate(now: referenceDate) == "Yesterday")
    }

    @Test
    func messageList_2DaysAgo_showsWeekday() {
        let date = makeDate(year: 2026, month: 7, day: 5)
        #expect(date.formatMessageListDate(now: referenceDate) == "Sunday")
    }

    @Test
    func messageList_6DaysAgo_showsWeekday() {
        let date = makeDate(year: 2026, month: 7, day: 2)
        #expect(date.formatMessageListDate(now: referenceDate) == "Thursday")
    }

    @Test
    func messageList_7DaysAgo_showsFullDate() {
        let date = makeDate(year: 2026, month: 6, day: 29)
        #expect(date.formatMessageListDate(now: referenceDate) == "29 June")
    }

    @Test
    func messageList_olderDate_showsFullDate() {
        let date = makeDate(year: 2026, month: 1, day: 15)
        #expect(date.formatMessageListDate(now: referenceDate) == "15 January")
    }

    @Test
    func messageList_differentYear_showsFullDate() {
        let date = makeDate(year: 2025, month: 12, day: 25)
        #expect(date.formatMessageListDate(now: referenceDate) == "25 December")
    }

    // MARK: - formatMessageDetailDate

    @Test
    func MessageDetail_today_showsTodayWithTime() {
        let date = makeDate(year: 2026, month: 7, day: 7, hour: 9, minute: 45)
        #expect(date.formatMessageDetailDate(now: referenceDate) == "Today, 9:45am")
    }

    @Test
    func MessageDetail_todayPM_showsTodayWithPMTime() {
        let date = makeDate(year: 2026, month: 7, day: 7, hour: 21, minute: 30)
        #expect(date.formatMessageDetailDate(now: referenceDate) == "Today, 9:30pm")
    }

    @Test
    func MessageDetail_yesterday_showsYesterdayWithTime() {
        let date = makeDate(year: 2026, month: 7, day: 6, hour: 10, minute: 33)
        #expect(date.formatMessageDetailDate(now: referenceDate) == "Yesterday, 10:33am")
    }

    @Test
    func MessageDetail_yesterdayPM_showsYesterdayWithPMTime() {
        let date = makeDate(year: 2026, month: 7, day: 6, hour: 14, minute: 5)
        #expect(date.formatMessageDetailDate(now: referenceDate) == "Yesterday, 2:05pm")
    }

    @Test
    func MessageDetail_olderDate_showsFullDateWithTime() {
        let date = makeDate(year: 2026, month: 4, day: 2, hour: 7, minute: 42)
        #expect(date.formatMessageDetailDate(now: referenceDate) == "2 April, 7:42am")
    }

    @Test
    func MessageDetail_differentYear_showsFullDateWithTime() {
        let date = makeDate(year: 2025, month: 12, day: 25, hour: 8, minute: 0)
        #expect(date.formatMessageDetailDate(now: referenceDate) == "25 December, 8:00am")
    }
}
