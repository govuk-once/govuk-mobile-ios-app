//
import Foundation

protocol NotificationCentreRepositoryInterface {
    func fetchAll() -> [Notification]
    func fetchNotification(with id: String) -> Notification?

    func store(notifications: [Notification])
    func updateNotification(with id: String, isUnread: Bool)
    func deleteNotification(with id: String)
}


class NotificationCentreRepository: NotificationCentreRepositoryInterface {
    enum Constants {
        static let notificationExpiration: TimeInterval = 30
    }

    private struct CacheEntry<T> {
        let data: T
        let lastUpdate: Date

        var hasExpired: Bool {
            Date().timeIntervalSince(lastUpdate) > Constants.notificationExpiration
        }
    }

    private var notifications: CacheEntry<[Notification]>?
    private var lastUpdate: Date?

    func fetchAll() -> [Notification] {
        guard let notifications else { return [] }
        return notifications.hasExpired ? [] : notifications.data
    }

    func fetchNotification(with id: String) -> Notification? {
        return notifications?.hasExpired == false ?
            notifications?.data.first(where: { $0.id == id }) :
            nil
    }

    func store(notifications: [Notification]) {
        self.notifications = .init(data: notifications, lastUpdate: .now)
    }

    func updateNotification(with id: String, isUnread: Bool) {
        guard let notifications else { return }

        let updatedNotifications = notifications.data.map {
            let unread = $0.id == id ? isUnread : $0.isUnread
            let status = unread ? "DELIVERED" : "READ"

            return Notification(
                id: $0.id,
                title: $0.title,
                body: $0.body,
                date: $0.date,
                status: status,
                messageTitle: $0.messageTitle,
                messageBody: $0.messageBody)
        }

        self.notifications = .init(data: updatedNotifications, lastUpdate: notifications.lastUpdate)
    }

    func deleteNotification(with id: String) {
        guard let notifications else { return }

        let updatedNotifications = notifications.data.filter { $0.id != id }

        self.notifications = .init(data: updatedNotifications, lastUpdate: notifications.lastUpdate)
    }
}
