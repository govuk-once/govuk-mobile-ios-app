//

protocol NotificationCentreServiceClientInterface {
    func fetchNotifications(callback: @escaping ([Notification]) -> Void)
    func fetchDetailedNotification(
        with id: String,
        callback: @escaping (DetailedNotification?) -> Void)
}

// swiftlint:disable todo
struct NotificationCentreServiceClient: NotificationCentreServiceClientInterface {
    func fetchNotifications(callback: @escaping ([Notification]) -> Void) {
        callback(NotificationCentreViewModel.MockData.testNotifications) // TODO Implement properly
    }

    func fetchDetailedNotification(with id: String,
                                   callback: @escaping (DetailedNotification?) -> Void) {
        callback(NotificationCentreViewModel.MockData
            .testDetailedNotifications.first(where: { // TODO Implement properly
                $0.notification.id == id
            }))
    }
}
// swiftlint:enable todo
