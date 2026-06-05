//

@testable import govuk_ios

class MockNotificationCentreRepository: NotificationCentreRepositoryInterface {
    var _fetchAllResponse: [govuk_ios.Notification] = []
    func fetchAll() -> [govuk_ios.Notification] {
        _fetchAllResponse
    }

    var _fetchNotificationResponse: govuk_ios.Notification?
    func fetchNotification(with id: String) -> govuk_ios.Notification? {
        _fetchNotificationResponse
    }

    var _storedNotifications: [govuk_ios.Notification]?
    func store(notifications: [govuk_ios.Notification]) {
        _storedNotifications = notifications
    }

    var _didUpdateNotificationId: String?
    var _didUpdateNotificationUnread: Bool?
    func updateNotification(with id: String, isUnread: Bool) {
        _didUpdateNotificationId = id
        _didUpdateNotificationUnread = isUnread
    }

    var _didDeleteNotificationId: String?
    func deleteNotification(with id: String) {
        _didDeleteNotificationId = id
    }
}
