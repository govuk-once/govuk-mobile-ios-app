import Combine
import Foundation
import GovKit

class NotificationCentreDetailViewModel: ObservableObject {
    enum State: Equatable {
        case new,
             loading,
             loaded(notification: NotificationDetailContent, showDeleteConfirmationSheet: Bool),
             error,
             noInternet
    }

    @Published public private(set) var state: State = .new

    private let notificationId: String
    private let notificationService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let actions: NotificationCentreDetailViewModel.Actions


    init(notificationId: String,
         notificationService: NotificationCentreServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         actions: NotificationCentreDetailViewModel.Actions
    ) {
        self.notificationId = notificationId
        self.notificationService = notificationService
        self.analyticsService = analyticsService
        self.actions = actions
    }

    struct NotificationDetailContent: Equatable {
        let title: String
        let body: String
        let sender: String
        let date: String
        let id: String

        init(title: String,
             body: String,
             sender: String,
             date: String,
             id: String) {
            self.title = title
            self.body = body
            self.sender = sender
            self.date = date
            self.id = id
        }

        init(notification: Notification) {
            self.title = notification.messageTitle ?? notification.title
            self.body = notification.messageBody ?? notification.body
            self.sender = notification.senderName
            self.date = notification.date.formatMessageDetailDate()
            self.id = notification.id
        }
    }

    func onViewAppear() {
        if case .new = state {
            loadData()
        }
    }

    @MainActor
    private func changeState(state: State) async {
        self.state = state
    }

    func loadData() {
        Task {
            await changeState(state: .loading)

            notificationService
                .fetchNotification(with: notificationId) { [weak self] res in
                    self?.processFetch(res)
                }
        }
    }

    fileprivate func processFetch(_ res: SingleNotificationResult) {
        Task { [weak self] in
            guard let self else { return }
            switch res {
            case .success(let notification):
                if let notification {
                    await self.changeState(
                        state: .loaded(
                            notification: NotificationDetailContent(notification: notification),
                            showDeleteConfirmationSheet: false))
                    if notification.isUnread {
                        self.notificationService.markRead(with: notification.id)
                    }
                } else {
                    self.analyticsService.track(event: .notificationCentreNotFound())
                    await self.changeState(state: .error)
                }
            case .failure(let error):
                if case .networkUnavailable = error {
                    await self.changeState(state: .noInternet)
                } else {
                    await self.changeState(state: .error)
                }
            }
        }
    }

    func show(url: URL) {
        actions.showUrlAction(url)
        analyticsService.track(event: .notificationCentreUrlLaunched(url: url))
    }

    func onDelete() {
        if case .loaded(let notification, _) = state {
            self.analyticsService.track(event: .notificationCentreDelete())
            self.state = .loaded(notification: notification, showDeleteConfirmationSheet: true)
        }
    }

    func onConfirmDelete() {
        if case .loaded(let notification, _) = state {
            analyticsService.track(event: .notificationCentreConfirmDelete())
            notificationService.delete(with: notification.id)
        }

        actions.onDeleteAction()
    }

    func onCancelDelete() {
        if case .loaded(let notification, _) = state {
            self.analyticsService.track(event: .notificationCentreCancelDelete())
            self.state = .loaded(notification: notification, showDeleteConfirmationSheet: false)
        }
    }

    func onMarkUnread() {
        if case .loaded(let notification, _) = state {
            analyticsService.track(event: .notificationCentreMarkUnread())
            notificationService.markUnread(with: notification.id)
        }

        actions.onUnreadAction()
    }

    func track(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}

extension NotificationCentreDetailViewModel {
    struct Actions {
        let showUrlAction: (URL) -> Void
        let onUnreadAction: () -> Void
        let onDeleteAction: () -> Void
    }
}
