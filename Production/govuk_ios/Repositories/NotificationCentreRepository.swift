//

protocol NotificationCentreRepositoryInterface {
    func fetchAll() -> [Notification]
    func fetchDetailedNotification(with id: String) -> DetailedNotification?
}

// swiftlint:disable todo
struct NotificationCentreRepository: NotificationCentreRepositoryInterface {
    func fetchAll() -> [Notification] {
        return [] // TODO Implement properly when not using mock data
    }

    func fetchDetailedNotification(with id: String) -> DetailedNotification? {
        return nil // TODO Implement properly when not using mock data
    }
}
// swiftlint:enable todo
