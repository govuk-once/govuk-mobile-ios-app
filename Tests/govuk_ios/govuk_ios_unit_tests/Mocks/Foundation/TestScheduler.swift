import Combine
import Foundation

/// A Combine scheduler whose clock only moves when a test calls `advance(by:)`,
/// so time-based operators such as `debounce` can be tested without waiting.
final class TestScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = Never

    private struct ScheduledAction {
        let id: Int
        let date: SchedulerTimeType
        let action: () -> Void
    }

    private var scheduled: [ScheduledAction] = []
    private var nextId = 0

    private(set) var now = SchedulerTimeType(DispatchTime(uptimeNanoseconds: 1))
    let minimumTolerance: SchedulerTimeType.Stride = .zero

    func schedule(options: Never?, _ action: @escaping () -> Void) {
        enqueue(at: now, action)
    }

    func schedule(after date: SchedulerTimeType,
                  tolerance: SchedulerTimeType.Stride,
                  options: Never?,
                  _ action: @escaping () -> Void) {
        enqueue(at: date, action)
    }

    func schedule(after date: SchedulerTimeType,
                  interval: SchedulerTimeType.Stride,
                  tolerance: SchedulerTimeType.Stride,
                  options: Never?,
                  _ action: @escaping () -> Void) -> Cancellable {
        var isCancelled = false
        func repeating(at date: SchedulerTimeType) {
            enqueue(at: date) { [weak self] in
                guard !isCancelled, let self else { return }
                action()
                repeating(at: self.now.advanced(by: interval))
            }
        }
        repeating(at: date)
        return AnyCancellable { isCancelled = true }
    }

    /// Runs, in order, every action due on or before `now + stride`.
    func advance(by stride: SchedulerTimeType.Stride = .zero) {
        let target = now.advanced(by: stride)
        while let next = scheduled
            .filter({ $0.date <= target })
            .min(by: { ($0.date, $0.id) < ($1.date, $1.id) }) {
            scheduled.removeAll { $0.id == next.id }
            if next.date > now {
                now = next.date
            }
            next.action()
        }
        now = target
    }

    private func enqueue(at date: SchedulerTimeType, _ action: @escaping () -> Void) {
        nextId += 1
        scheduled.append(ScheduledAction(id: nextId, date: date, action: action))
    }
}
