//

import Combine
import Foundation

struct Notification: Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let isUnread: Bool
}

class NotificationCentreViewModel: ObservableObject {
    struct MockData {
        static let testNotifications: [Notification] = {
            let oneDay: Double = 60 * 60 * 24
            let now = Date(timeIntervalSince1970: 1772198784) // Fri, 27 Feb 2026 13:26:24 GMT
            return [.init(id: "1", title: "Test 1 with a really really really long title that will surely be chopped off if we add enough filler text to the end so it goes to more than two lines", body: "Body 1", date: now, isUnread: true),
                    .init(id: "2", title: "Test 2", body: "Body 2 with a really really really large amount of text that will definitely make the text longer than it should be and so will get chopped off and ellipsized", date: now.addingTimeInterval(-1 * oneDay), isUnread: true),
                    .init(id: "3", title: "Test 3", body: "Body 3", date: now.addingTimeInterval(-1 * oneDay * 2), isUnread: false),
                    .init(id: "4", title: "Test 4", body: "Body 4", date: now.addingTimeInterval(-1 * oneDay * 3), isUnread: true)
            ]
        }()
    }
    enum State {
        case new, loading, empty, loaded(notifications: [Notification]), error
    }
    
    @Published public private(set) var state: State = .new
    
    private let actions: Actions
    private let notificationService: NotificationCentreServiceInterface
    
    init(actions: Actions, notificationService: NotificationCentreServiceInterface) {
        self.actions = actions
        self.notificationService = notificationService
    }
    
    func onViewAppear() {
        if case .new = state {
            loadData()
        }
    }
    
    func onTapRetry() {
        guard case .error = state else {
            return
        }
        
        loadData()
    }
    
    func onTapNotification(notification: Notification) {
        actions.showNotification(notification)
    }
    
    private func changeState(state: State) async {
        await MainActor.run {
            self.state = state
        }
    }
    
    func loadData() {
        Task {
            await changeState(state: .loading)
            
            try await Task.sleep(for: .seconds(2))
            
            notificationService.fetchNotifications { notifications in
                Task {
                    let sorted = notifications.sorted {
                        $0.date > $1.date
                    }
                    await self.changeState(state: .loaded(notifications: sorted))
                }
            }
            
        }
    }
}

extension NotificationCentreViewModel {
    struct Actions {
        let showNotification: (Notification) -> Void
    }
}
