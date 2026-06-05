import Foundation

extension Date {
    public func isToday(calendar: Calendar = .current) -> Bool {
        calendar.isDateInToday(self)
    }

    public func isThisMonth(calendar: Calendar = .current) -> Bool {
        calendar.isDate(
            self,
            equalTo: Date(),
            toGranularity: .month
        )
    }

    // MARK: - Messages

    /**
     Formats a date to match the rules for Message List

     Today -> Today, 9:45pm

     Yesterday -> Yesterday

     Last 7 days -> Tuesday

     Else -> 7 December
     */
    public func formatMessageListDate() -> String {
        let london = TimeZone(identifier: "Europe/London")!
        var calendar = Calendar.current
        calendar.timeZone = london

        let now = Date()

        let formatter = DateFormatter()
        formatter.timeZone = london
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        if calendar.isDateInToday(self) {
            formatter.dateFormat = "'Today,' h:mma"
        } else if calendar.isDateInYesterday(self) {
            // Bit unnecessary, but lets us keep it consistent and have a single return
            formatter.dateFormat = "'Yesterday'"
        } else if let daysAgo = calendar.dateComponents([.day], from: self, to: now).day,
                    daysAgo < 7 {
            formatter.dateFormat = "EEEE"
        } else {
            formatter.dateFormat = "d MMMM"
        }
        return formatter.string(from: self)
    }

    /**
     Formats a date to match the rules for Message Detail

     Today -> Today, 9:45pm

     Yesterday -> Yesterday, 10:33am

     Else -> 2 April, 7:42am
     */
    public func formatMessageDetailDate() -> String {
        let london = TimeZone(identifier: "Europe/London")!
        var calendar = Calendar.current
        calendar.timeZone = london

        let formatter = DateFormatter()
        formatter.timeZone = london
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        if calendar.isDateInToday(self) {
            formatter.dateFormat = "'Today,' h:mma"
        } else if calendar.isDateInYesterday(self) {
            formatter.dateFormat = "'Yesterday,' h:mma"
        } else {
            formatter.dateFormat = "d MMMM, h:mma"
        }

        return formatter.string(from: self)
    }
}
