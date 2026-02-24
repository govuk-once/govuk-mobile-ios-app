//

protocol NotificationCentreServiceClientInterface {
    func fetchNotifications(callback: @escaping([Notification]) -> Void)
}

struct NotificationCentreServiceClient: NotificationCentreServiceClientInterface {
    func fetchNotifications(callback: @escaping ([Notification]) -> Void) {
        callback(NotificationCentreViewModel.MockData.testNotifications) // TODO Implement properly
    }
}
