import Foundation

protocol NotificationCentreRepositoryInterface {
    func fetchAll() -> [Notification]
    func fetchNotification(with id: String) -> Notification?

    func store(notifications: [Notification])
    func updateNotification(with id: String, isUnread: Bool)
    func deleteNotification(with id: String)
}

class NotificationCentreRepository: NotificationCentreRepositoryInterface {
    class DateProvider {
        open var currentDate: Date {
            Date()
        }
    }

    private struct CacheEntry<T> {
        private let notificationExpiration: TimeInterval = 30

        let data: T
        let lastUpdate: Date

        func hasExpired(with date: Date) -> Bool {
            date.timeIntervalSince(lastUpdate) > notificationExpiration
        }
    }

    private var notifications: CacheEntry<[Notification]>?
    private var lastUpdate: Date?

    private var dateProvider: DateProvider

    init(dateProvider: DateProvider = .init()) {
        self.dateProvider = dateProvider
    }

    func fetchAll() -> [Notification] {
        guard let notifications else { return [] }
        return notifications.hasExpired(with: dateProvider.currentDate) ? [] : notifications.data
    }

    func fetchNotification(with id: String) -> Notification? {
        return notifications?.hasExpired(with: dateProvider.currentDate) == false ?
            notifications?.data.first(where: { $0.id == id }) :
            nil
    }

    func store(notifications: [Notification]) {
        self.notifications = .init(data: notifications, lastUpdate: dateProvider.currentDate)
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
                messageBody: $0.messageBody,
                metadata: $0.metadata)
        }

        self.notifications = .init(data: updatedNotifications, lastUpdate: notifications.lastUpdate)
    }

    func deleteNotification(with id: String) {
        guard let notifications else { return }

        let updatedNotifications = notifications.data.filter { $0.id != id }

        self.notifications = .init(data: updatedNotifications, lastUpdate: notifications.lastUpdate)
    }
}
