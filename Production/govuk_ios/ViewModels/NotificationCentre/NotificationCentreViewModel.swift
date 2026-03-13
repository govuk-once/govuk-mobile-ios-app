//

import Combine
import Foundation
import GovKit

struct Notification: Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let isUnread: Bool
}

struct DetailedNotification: Identifiable {
    var id: String {
        notification.id
    }

    let notification: Notification
    let messageTitle: String?
    let messageBody: String?
}

class NotificationCentreViewModel: ObservableObject {
    // swiftlint:disable line_length
    struct MockData {
        static let testNotifications: [Notification] = {
            let oneDay: Double = 60 * 60 * 24
            let now = Date(timeIntervalSince1970: 1772198784) // Fri, 27 Feb 2026 13:26:24 GMT
            return [.init(id: "1", title: "Test 1 with a really really really long title that will surely be chopped off if we add enough filler text to the end so it goes to more than two lines", body: "Body 1", date: now, isUnread: true),
                    .init(id: "2", title: "Test 2", body: "Body 2 with a really really really large amount of text that will definitely make the text longer than it should be and so will get chopped off and ellipsized", date: now.addingTimeInterval(-1 * oneDay), isUnread: true),
                    .init(id: "3", title: "Test 3 read", body: "Body 3 read", date: now.addingTimeInterval(-1 * oneDay * 2), isUnread: false),
                    .init(id: "4", title: "Test 4 with a seriously massive amount of text in the title that will span multiple", body: "Body 4 with a stupendous amount of body text lorem ipsum dolor sit amet https://google.com Kindling the energy hidden in matter Tunguska event muse about Cambrian explosion network of wormholes realm of the galaxies. At the edge of forever extraordinary claims require extraordinary evidence gathered by gravity two ghostly white figures in coveralls and helmets are softly dancing emerged into consciousness a still more glorious dawn awaits. Rings of Uranus something incredible is waiting to be known a mote of dust suspended in a sunbeam descended from astronomers concept of the number one the carbon in our apple pies and billions upon billions upon billions upon billions upon billions upon billions upon billions.", date: now.addingTimeInterval(-1 * oneDay * 3), isUnread: true),
                    .init(id: "5", title: "Test 5 with an alternate title", body: "Body 5", date: now.addingTimeInterval(-1 * oneDay * 4), isUnread: false),
                    .init(id: "6", title: "Test 6 with an alternate body", body: "Body 6", date: now.addingTimeInterval(-1 * oneDay * 5), isUnread: false),
                    .init(id: "7", title: "Test 7 with an alternate title and body", body: "Body 7", date: now.addingTimeInterval(-1 * oneDay * 6), isUnread: false),
            ]
        }()

        static let testDetailedNotifications: [DetailedNotification] = {
            let notifications = testNotifications

            return [
                .init(notification: notifications[0], messageTitle: nil, messageBody: nil),
                .init(notification: notifications[1], messageTitle: nil, messageBody: nil),
                .init(notification: notifications[2], messageTitle: nil, messageBody: nil),
                .init(notification: notifications[3], messageTitle: nil, messageBody: nil),
                .init(notification: notifications[4], messageTitle: "Alternate message title", messageBody: nil),
                .init(notification: notifications[5], messageTitle: nil, messageBody: "Alternate message body"),
                .init(notification: notifications[6], messageTitle: "Alternate message title 2", messageBody: "Alternate message body 2 Purr as loud as possible, be the most annoying cat that you can, and, knock everything off the table grass smells good and proudly present butt to human but attack curtains, or dream about hunting birds. Going to catch the red dot today going to catch the red dot today sleep on dog bed, force dog to sleep on floor. Poop on couch. Pet me pet me pet me pet me, bite, scratch, why are you petting me miaow then turn around and show you my bum so walk on a keyboard and kitty kitty pussy cat doll munch on tasty moths. Furball roll roll roll meow all night, get video posted to internet for chasing red dot yet one of these days i'm going to get that red dot, just you wait and see ooh, are those your $250 dollar sandals? lemme use that as my litter box. Eat and than sleep on your face the dog smells bad rub my belly hiss eat the fat cats food. Make plans to dominate world and then take a nap bury the poop bury it deep or pretend you want to go out but then don't. Steal mom's crouton while she is in the bathroom destroy dog. Caticus cuteicus annoy the old grumpy cat, start a fight and then retreat to wash when i lose. Run outside as soon as door open. Check cat door for ambush 10 times before coming in meow and walk away and i like cats because they are fat and fluffy and behind the couch, and swat turds around the house for have a lot of grump in yourself because you can't forget to be grumpy and not be like king grumpy cat where is my slave? I'm getting hungry. There's a forty year old lady there let us feast eats owners hair then claws head, give me some of your food give me some of your food give me some of your food meh, i don't want it. I shredded your linens for you.")
            ]
        }()
    }
    // swiftlint:enable line_length

    enum State {
        case new, loading, empty, loaded(notifications: [Notification]), error
    }

    @Published public private(set) var state: State = .new

    private let actions: Actions
    private let notificationService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface

    init(
        actions: Actions,
        notificationService: NotificationCentreServiceInterface,
        analyticsService: AnalyticsServiceInterface) {
            self.actions = actions
            self.notificationService = notificationService
            self.analyticsService = analyticsService
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

            try await Task.sleep(for: .seconds(0.5))

            notificationService.fetchNotifications { notifications in
                Task {
                    if notifications.isEmpty {
                        await self.changeState(state: .empty)
                    } else {
                        let sorted = notifications.sorted {
                            $0.date > $1.date
                        }
                        await self.changeState(state: .loaded(notifications: sorted))
                    }
                }
            }
        }
    }

    func track(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}

extension NotificationCentreViewModel {
    struct Actions {
        let showNotification: (Notification) -> Void
    }
}
