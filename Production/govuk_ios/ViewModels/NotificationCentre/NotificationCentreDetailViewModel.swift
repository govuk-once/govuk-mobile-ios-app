//

import Combine
import Foundation
import GovKit

class NotificationCentreDetailViewModel: ObservableObject {
    enum State {
        case new, loading, notFound,
             loaded(notification: Notification, showDeleteConfirmationSheet: Bool), error
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

            notificationService
                .fetchNotification(with: notificationId) { [weak self] res in
                    Task {
                        if case let .success(notification) = res {
                            if let notification {
                                await self?.changeState(
                                    state: .loaded(
                                        notification: notification,
                                        showDeleteConfirmationSheet: false))
                                if notification.isUnread {
                                    self?.notificationService.markRead(with: notification.id)
                                }
                            } else {
                                self?.analyticsService.track(event: .notificationCentreNotFound())
                                await self?.changeState(state: .notFound)
                            }
                        } else if case let .failure(error) = res,
                                    error == NotificationCentreError.notFound {
                            await self?.changeState(state: .notFound)
                        } else {
                            await self?.changeState(state: .error)
                        }
                    }
                }
        }
    }

    func show(url: URL) {
        showUrlAction(url)
    }

    func onDelete() {
        if case .loaded(let notification, _) = state {
            self.analyticsService.track(event: .notificationCentreDelete())
            self.state = .loaded(notification: notification, showDeleteConfirmationSheet: true)
        }
    }

    func onConfirmDelete() {
        if case .loaded(let notification, _) = state {
            self.analyticsService.track(event: .notificationCentreConfirmDelete())
            Task { [weak self] in
                self?.notificationService.delete(with: notification.id)
            }
        }

        onDeleteAction()
    }

    func onCancelDelete() {
        if case .loaded(let notification, _) = state {
            self.analyticsService.track(event: .notificationCentreCancelDelete())
            self.state = .loaded(notification: notification, showDeleteConfirmationSheet: false)
        }
    }

    func onMarkUnread() {
        if case .loaded(let notification, _) = state {
            Task { [weak self] in
                self?.notificationService.markUnread(with: notification.id)
            }
        }

        onUnreadAction()
    }

    func track(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func track(url: URL) {
        analyticsService.track(event: .notificationCentreUrlLaunched(url: url))
    }
}
