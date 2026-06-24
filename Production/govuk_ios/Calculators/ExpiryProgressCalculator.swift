import Foundation

struct ExpiryProgressState {
    let daysLeft: Int
    let progress: CGFloat
    let isWithinCountdownWindow: Bool
}

struct ExpiryProgressCalculator {
    private let calendar: Calendar
    private let countdownWindowDays: Int

    init(calendar: Calendar = .dvla, countdownWindowDays: Int) {
        self.calendar = calendar
        self.countdownWindowDays = countdownWindowDays
    }

    func calculate(
        expiryDate: Date,
        currentDate: Date = Date()
    ) -> ExpiryProgressState {
        let today = calendar.startOfDay(for: currentDate)
        let expiry = calendar.startOfDay(for: expiryDate)

        let components = calendar.dateComponents([.day], from: today, to: expiry)
        let rawDaysLeft = components.day ?? 0
        let daysLeft = max(0, rawDaysLeft)
        let progress = min(1.0, CGFloat(daysLeft) / CGFloat(countdownWindowDays))

        return ExpiryProgressState(
            daysLeft: daysLeft,
            progress: progress,
            isWithinCountdownWindow: daysLeft <= countdownWindowDays
        )
    }
}
