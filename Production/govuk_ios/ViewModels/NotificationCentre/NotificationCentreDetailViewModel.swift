//

import Combine

class NotificationCentreDetailViewModel: ObservableObject {
    let notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
}
