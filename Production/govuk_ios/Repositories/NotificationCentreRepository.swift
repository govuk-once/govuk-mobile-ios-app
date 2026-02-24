//

protocol NotificationCentreRepositoryInterface {
    func fetch() -> [Notification]
}

struct NotificationCentreRepository: NotificationCentreRepositoryInterface {
    func fetch() -> [Notification] {
        return [] // TODO Implement properly when not using mock data
    }
}
