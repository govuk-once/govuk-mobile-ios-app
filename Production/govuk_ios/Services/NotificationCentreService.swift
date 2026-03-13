//

protocol NotificationCentreServiceInterface {
    func fetchNotifications(callback: @escaping (([Notification]) -> Void))
    func fetchDetailedNotification(notificationId: String,
                                   callback: @escaping ((DetailedNotification?) -> Void))
}

class NotificationCentreService: NotificationCentreServiceInterface {
    let serviceClient: NotificationCentreServiceClientInterface
    let repository: NotificationCentreRepositoryInterface

    init(
        serviceClient: NotificationCentreServiceClientInterface,
        repository: NotificationCentreRepositoryInterface) {
        self.serviceClient = serviceClient
        self.repository = repository
    }

    func fetchNotifications(callback: @escaping ([Notification]) -> Void) {
        // swiftlint:disable:next todo
        // TODO Implement properly when not using mock data
        let cached = repository.fetchAll()

        if cached.isEmpty {
            return serviceClient.fetchNotifications { notifications in
                callback(notifications)
            }
        } else {
            callback(cached)
        }
    }

    func fetchDetailedNotification(
        notificationId: String, callback:
        @escaping (DetailedNotification?) -> Void) {
        // swiftlint:disable:next todo
        // TODO Implement properly when not using mock data
        if let cached = repository.fetchDetailedNotification(with: notificationId) {
            callback(cached)
        } else {
            return serviceClient.fetchDetailedNotification(with: notificationId) { notification in
                callback(notification)
            }
        }
    }
}
