//

protocol NotificationCentreServiceInterface {
    func fetchNotifications(callback: @escaping (([Notification]) -> Void))
}

class NotificationCentreService: NotificationCentreServiceInterface {
    let serviceClient: NotificationCentreServiceClientInterface
    let repository: NotificationCentreRepositoryInterface
    
    init(serviceClient: NotificationCentreServiceClientInterface, repository: NotificationCentreRepositoryInterface) {
        self.serviceClient = serviceClient
        self.repository = repository
    }
    
    func fetchNotifications(callback: @escaping ([Notification]) -> Void) {
        // TODO Implement properly when not using mock data
        let cached = repository.fetch()
        
        if cached.isEmpty {
            return serviceClient.fetchNotifications { notifications in
                callback(notifications)
            }
        }
        else {
            callback(cached)
        }
    }
    
}
