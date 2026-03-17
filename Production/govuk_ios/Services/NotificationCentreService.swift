//

protocol NotificationCentreServiceInterface {
    func fetchNotifications(callback: @escaping ((NotificationResult) -> Void))
    func fetchNotification(with id: String,
                           callback: @escaping (SingleNotificationResult) -> Void)

    func markUnread(with id: String)
    func markRead(with id: String)
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

    func fetchNotifications(callback: @escaping (NotificationResult) -> Void) {
        let cached = repository.fetchAll()

        if cached.isEmpty == true {
            return serviceClient.fetchNotifications { [weak self] in
                if case let .success(notifications) = $0 {
                    self?.repository.store(notifications: notifications)
                }
                callback($0)
            }
        } else {
            callback(.success(cached))
        }
    }

    func fetchNotification(with id: String, callback:
        @escaping (SingleNotificationResult) -> Void) {
        if let cached = repository.fetchNotification(with: id) {
            callback(.success(cached))
        } else {
            return serviceClient.fetchNotification(with: id, callback: callback)
        }
    }

    func markUnread(with id: String) {
        repository.updateNotification(with: id, isUnread: true)
        serviceClient.updateNotification(status: .unread, for: id) {
            /* No-op */
        }
    }

    func markRead(with id: String) {
        repository.updateNotification(with: id, isUnread: false)
        serviceClient.updateNotification(status: .read, for: id) {
            /* No-op */
        }
    }
}
