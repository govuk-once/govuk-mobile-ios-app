//

import Foundation

@testable import govuk_ios

class MockNotificationCentreService: NotificationCentreServiceInterface {
    var _stubbedFetchNotificationsResult: govuk_ios.NotificationResult!
    var _fetchNotificationsCalled: Bool?
    var _onFetchNotificationsCalled: (() -> Void)?
    func fetchNotifications(callback: @escaping (govuk_ios.NotificationResult) -> Void) {
        _fetchNotificationsCalled = true
        callback(_stubbedFetchNotificationsResult)
        _onFetchNotificationsCalled?()
    }

    var _stubbedFetchNotificationResult: govuk_ios.SingleNotificationResult!
    var _fetchNotificationCalledWithId: String?
    var _onFetchNotificationCalled: (() -> Void)?
    func fetchNotification(
        with id: String,
        callback: @escaping (govuk_ios.SingleNotificationResult) -> Void) {
        _fetchNotificationCalledWithId = id
        callback(_stubbedFetchNotificationResult)
        _onFetchNotificationCalled?()
    }

    var _markUnreadCalledWithId: String?
    var _onMarkUnreadCalled: (() -> Void)?
    func markUnread(with id: String) {
        _markUnreadCalledWithId = id
        _onMarkUnreadCalled?()
    }

    var _markReadCalledWithId: String?
    func markRead(with id: String) {
        _markReadCalledWithId = id
    }

    var _deleteCalledWithId: String?
    var _onDeleteCalled: (() -> Void)?
    func delete(with id: String) {
        _deleteCalledWithId = id
        _onDeleteCalled?()
    }
}
