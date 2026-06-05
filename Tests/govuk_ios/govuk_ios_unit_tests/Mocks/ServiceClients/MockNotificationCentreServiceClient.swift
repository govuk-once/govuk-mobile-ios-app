//

@testable import govuk_ios

class MockNotificationCentreServiceClient: NotificationCentreServiceClientInterface {
    var _fetchNotificationsResult: govuk_ios.NotificationResult!
    func fetchNotifications(callback: @escaping (govuk_ios.NotificationResult) -> Void) {
        callback(_fetchNotificationsResult)
    }

    var _fetchNotificationResult: govuk_ios.SingleNotificationResult!
    func fetchNotification(with id: String, callback: @escaping (govuk_ios.SingleNotificationResult) -> Void) {
        callback(_fetchNotificationResult)
    }

    var _didUpdateNotificationStatus: govuk_ios.GOVRequest.UpdateBody.Status?
    var _didUpdateNotificationID: String?
    func updateNotification(status: govuk_ios.GOVRequest.UpdateBody.Status, for id: String, with callback: @escaping () -> Void) {
        _didUpdateNotificationStatus = status
        _didUpdateNotificationID = id
        callback()
    }

    var _didDeleteNotificationId: String?
    func deleteNotification(with id: String, callback: @escaping () -> Void) {
        _didDeleteNotificationId = id
        callback()
    }
}
