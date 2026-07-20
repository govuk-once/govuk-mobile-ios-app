import Combine
import Foundation
import GovKit

struct Notification: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let status: String
    let messageTitle: String?
    let messageBody: String?
    let metadata: Metadata

    struct Metadata: Codable, Equatable {
        struct Sender: Codable, Equatable {
            let displayName: String
            // swiftlint:disable:next nesting
            enum CodingKeys: String, CodingKey {
                case displayName = "DisplayName"
            }
        }

        let sender: Sender

        enum CodingKeys: String, CodingKey {
            case sender = "Sender"
        }
    }
    var isUnread: Bool {
        status != "READ"
    }

    var senderName: String {
        metadata.sender.displayName
    }

    enum CodingKeys: String, CodingKey {
        case id = "NotificationID"
        case title = "NotificationTitle"
        case body = "NotificationBody"
        case date = "DispatchedDateTime"
        case status = "Status"
        case messageTitle = "MessageTitle"
        case messageBody = "MessageBody"
        case metadata = "Metadata"
    }
}

class NotificationCentreViewModel: ObservableObject {
    enum State: Equatable {
        case loading,
             empty,
             loaded(notifications: NotificationGroups),
             error,
             noInternet
    }

    public struct NotificationGroups: Equatable {
        let recent: [NotificationListItem]
        let older: [NotificationListItem]
    }

    public struct NotificationListItem: Equatable, Identifiable {
        let title: String
        let date: String
        let isUnread: Bool
        let id: String

        init(title: String, date: String, isUnread: Bool, id: String) {
            self.title = title
            self.date = date
            self.isUnread = isUnread
            self.id = id
        }

        init(notification: Notification) {
            self.title = notification.title
            self.date = notification.date.formatMessageListDate()
            self.isUnread = notification.isUnread
            self.id = notification.id
        }
    }

    class DateProvider {
        open var currentDate: Date {
            Date()
        }
    }

    @Published public private(set) var state: State = .loading

    private let actions: Actions
    private let notificationCentreService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let dateProvider: DateProvider

    init(
        actions: Actions,
        notificationCentreService: NotificationCentreServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        dateProvider: DateProvider = .init()) {
            self.actions = actions
            self.notificationCentreService = notificationCentreService
            self.analyticsService = analyticsService
            self.dateProvider = dateProvider
        }

    func onViewAppear() {
        loadData()
    }

    func onTapNotification(notification: String) {
        actions.showNotification(notification)
    }

    @MainActor
    private func changeState(state: State) async {
        self.state = state
    }

    fileprivate func processFetch(_ res: NotificationResult) {
        Task { [weak self] in
            guard let self else { return }
            switch res {
            case .success(let notifications):
                if notifications.isEmpty {
                    await self.changeState(state: .empty)
                } else {
                    let sorted = notifications.sorted {
                        $0.date > $1.date
                    }

                    let sevenDaysBack = self.dateProvider
                        .currentDate.addingTimeInterval(-7 * 24.0 * 60.0 * 60.0)

                    let recent = sorted.filter {
                        $0.date >= sevenDaysBack
                    }.map {
                        NotificationListItem(notification: $0)
                    }

                    let older = sorted.filter {
                        $0.date < sevenDaysBack
                    }.map {
                        NotificationListItem(notification: $0)
                    }

                    let buckets = NotificationGroups(
                        recent: recent, older: older)

                    await self.changeState(state: .loaded(notifications: buckets))
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

    func loadData() {
        Task {
            await changeState(state: .loading)

            notificationCentreService.fetchNotifications { [weak self] res in
                self?.processFetch(res)
            }
        }
    }

    func track(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}

extension NotificationCentreViewModel {
    struct Actions {
        let showNotification: (String) -> Void
    }
}
