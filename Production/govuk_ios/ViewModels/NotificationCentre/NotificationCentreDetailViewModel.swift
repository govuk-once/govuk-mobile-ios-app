//

import Combine
import Foundation
import GovKit

class NotificationCentreDetailViewModel: ObservableObject {
    enum State {
        case new, loading, notFound, loaded(notification: DetailedNotification), error
    }

    @Published public private(set) var state: State = .new

    private let notificationId: String
    private let notificationService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let showUrlAction: (URL) -> Void
    private let onUnreadAction: () -> Void
    private let onDeleteAction: () -> Void

    init(
        notificationId: String,
        notificationService: NotificationCentreServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        showUrlAction: @escaping (URL) -> Void,
        onUnreadAction: @escaping () -> Void,
        onDeleteAction: @escaping () -> Void) {
            self.notificationId = notificationId
            self.notificationService = notificationService
            self.analyticsService = analyticsService
            self.showUrlAction = showUrlAction
            self.onUnreadAction = onUnreadAction
            self.onDeleteAction = onDeleteAction
        }

    func onViewAppear() {
        if case .new = state {
            loadData()
            // swiftlint:disable:next todo
            // TODO Send read if necessary
        }
    }

    func onTapRetry() {
        guard case .error = state else {
            return
        }

        loadData()
    }

    private func changeState(state: State) async {
        await MainActor.run {
            self.state = state
        }
    }

    func loadData() {
        Task {
            await changeState(state: .loading)

            try await Task.sleep(for: .seconds(0.5))

            notificationService
                .fetchDetailedNotification(notificationId: notificationId) { notification in
                    Task {
                        if let notification {
                            await self.changeState(state: .loaded(notification: notification))
                        } else {
                            await self.changeState(state: .notFound)
                        }
                    }
                }
        }
    }

    func show(url: URL) {
        showUrlAction(url)
    }

    func onDelete() {
        // swiftlint:disable:next todo
        // TODO Send API call
        onDeleteAction()
    }

    func onMarkUnread() {
        // swiftlint:disable:next todo
        // TODO Send API call
        onUnreadAction()
    }

    func track(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func track(url: URL) {
        analyticsService.track(event: .notificationCentreUrlLaunched(url: url))
    }
}
