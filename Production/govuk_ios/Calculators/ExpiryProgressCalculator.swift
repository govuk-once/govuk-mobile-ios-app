import Foundation

struct ExpiryProgressState {
    let daysLeft: Int
    let progress: CGFloat
    let isWithinCountdownWindow: Bool
}

enum ExpiryProgressCalculator {
    static func calculate(
        expiryDate: Date,
        countdownWindow: Int,
        currentDate: Date = Date()
    ) -> ExpiryProgressState {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        let expiry = calendar.startOfDay(for: expiryDate)

        let components = calendar.dateComponents([.day], from: today, to: expiry)
        let rawDaysLeft = components.day ?? 0
        let daysLeft = max(0, rawDaysLeft)
        let progress = min(1.0, CGFloat(daysLeft) / CGFloat(countdownWindow))

        return ExpiryProgressState(
            daysLeft: daysLeft,
            progress: progress,
            isWithinCountdownWindow: daysLeft <= countdownWindow
        )
    }
}
