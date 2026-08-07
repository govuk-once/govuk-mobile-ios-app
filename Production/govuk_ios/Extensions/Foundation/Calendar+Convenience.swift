import Foundation

extension Calendar {
    static var dvla: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        if let timeZone = TimeZone(identifier: "Europe/London") {
            calendar.timeZone = timeZone
        }
        return calendar
    }
}
