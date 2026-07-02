//

import Combine
import Foundation
import GovKit

struct Notification: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let status: String
    let messageTitle: String?
    let messageBody: String?

    var isUnread: Bool {
        status != "READ"
    }

    var senderName: String {
        "Placeholder Sender"
    }

    enum CodingKeys: String, CodingKey {
        case id = "NotificationID"
        case title = "NotificationTitle"
        case body = "NotificationBody"
        case date = "DispatchedDateTime"
        case status = "Status"
        case messageTitle = "MessageTitle"
        case messageBody = "MessageBody"
    }
}

class NotificationCentreViewModel: ObservableObject {
    // swiftlint:disable line_length
    struct MockData {
        static let testNotifications: NotificationGroups = {
            let oneDay: Double = 60 * 60 * 24
            let now = Date(timeIntervalSince1970: 1772198784) // Fri, 27 Feb 2026 13:26:24 GMT
            let recent: [Notification] = [
                .init(id: "1", title: "Test 1 with a really really really long title that will surely be chopped off if we add enough filler text to the end so it goes to more than two lines", body: "Body 1", date: now, status: "UNREAD", messageTitle: nil, messageBody: nil),
                        .init(id: "2", title: "Test 2", body: "Body 2 with a really really really large amount of text that will definitely make the text longer than it should be and so will get chopped off and ellipsized", date: now.addingTimeInterval(-1 * oneDay), status: "UNREAD", messageTitle: nil, messageBody: nil),
                        .init(id: "3", title: "Test 3 read", body: "Body 3 read", date: now.addingTimeInterval(-1 * oneDay * 2), status: "READ", messageTitle: nil, messageBody: nil),
                        .init(id: "4", title: "Test 4 with a seriously massive amount of text in the title that will span multiple", body: "Body 4 with a stupendous amount of body text lorem ipsum dolor sit amet https://google.com Kindling the energy hidden in matter Tunguska event muse about Cambrian explosion network of wormholes realm of the galaxies. At the edge of forever extraordinary claims require extraordinary evidence gathered by gravity two ghostly white figures in coveralls and helmets are softly dancing emerged into consciousness a still more glorious dawn awaits. Rings of Uranus something incredible is waiting to be known a mote of dust suspended in a sunbeam descended from astronomers concept of the number one the carbon in our apple pies and billions upon billions upon billions upon billions upon billions upon billions upon billions.", date: now.addingTimeInterval(-1 * oneDay * 3), status: "UNREAD", messageTitle: "Alternate message title", messageBody: nil),
                        .init(id: "5", title: "Test 5 with an alternate title", body: "Body 5", date: now.addingTimeInterval(-1 * oneDay * 4), status: "READ", messageTitle: nil, messageBody: "Alternate message body"),
                        .init(id: "6", title: "Test 6 with an alternate body", body: "Body 6", date: now.addingTimeInterval(-1 * oneDay * 5), status: "READ", messageTitle: nil, messageBody: nil),
                        .init(id: "7", title: "Test 7 with an alternate title and body", body: "Body 7", date: now.addingTimeInterval(-1 * oneDay * 6), status: "READ", messageTitle: "Alternate message title 2", messageBody: "Alternate message body 2 Purr as loud as possible, be the most annoying cat that you can, and, knock everything off the table grass smells good and proudly present butt to human but attack curtains, or dream about hunting birds. Going to catch the red dot today going to catch the red dot today sleep on dog bed, force dog to sleep on floor. Poop on couch. Pet me pet me pet me pet me, bite, scratch, why are you petting me miaow then turn around and show you my bum so walk on a keyboard and kitty kitty pussy cat doll munch on tasty moths. Furball roll roll roll meow all night, get video posted to internet for chasing red dot yet one of these days i'm going to get that red dot, just you wait and see ooh, are those your $250 dollar sandals? lemme use that as my litter box. Eat and than sleep on your face the dog smells bad rub my belly hiss eat the fat cats food. Make plans to dominate world and then take a nap bury the poop bury it deep or pretend you want to go out but then don't. Steal mom's crouton while she is in the bathroom destroy dog. Caticus cuteicus annoy the old grumpy cat, start a fight and then retreat to wash when i lose. Run outside as soon as door open. Check cat door for ambush 10 times before coming in meow and walk away and i like cats because they are fat and fluffy and behind the couch, and swat turds around the house for have a lot of grump in yourself because you can't forget to be grumpy and not be like king grumpy cat where is my slave? I'm getting hungry. There's a forty year old lady there let us feast eats owners hair then claws head, give me some of your food give me some of your food give me some of your food meh, i don't want it. I shredded your linens for you.")
            ]

            let older: [Notification] = [
                .init(id: "8", title: "Test 8 for 8 days", body: "Body 1", date: now.addingTimeInterval(-1 * oneDay * 8), status: "UNREAD", messageTitle: nil, messageBody: nil),
                        .init(id: "9", title: "Test 8 for 2 weeks", body: "Body 1", date: now.addingTimeInterval(-1 * oneDay * 14), status: "UNREAD", messageTitle: nil, messageBody: nil),
                        .init(id: "10", title: "Test 8 for 3 weeks", body: "Body 1", date: now.addingTimeInterval(-1 * oneDay * 21), status: "UNREAD", messageTitle: nil, messageBody: nil),
                        .init(id: "11", title: "Test 8 for 4 weeks", body: "Body 1", date: now.addingTimeInterval(-1 * oneDay * 28), status: "UNREAD", messageTitle: nil, messageBody: nil)
            ]
            return NotificationGroups(recent: recent, older: older)
        }()

        static let tidyTestNotifications: NotificationGroups = {
            let oneDay: Double = 60 * 60 * 24
            let now = Date()

            let recent: [Notification] = [
                // Unread — urgent, long enough to ellipsise on one line
                .init(
                    id: "1",
                    title: "Action required: your Universal Credit claim needs attention by 30th July 2026",
                    body: "We need some additional information to continue processing your claim. Please sign in and upload the requested documents.",
                    date: now,
                    status: "UNREAD",
                    messageTitle: nil,
                    messageBody: nil
                ),
                // Unread — short title
                .init(
                    id: "2",
                    title: "MOT reminder: your vehicle is due for its MOT test",
                    body: "Your vehicle (**AB12 CDE**) is due for an MOT by *28 June 2026*. Book online or find an approved garage near you.",
                    date: now.addingTimeInterval(-1 * oneDay),
                    status: "UNREAD",
                    messageTitle: nil,
                    messageBody: nil
                ),
                // Read — uses messageTitle/messageBody to verify detail screen rendering
                .init(
                    id: "3",
                    title: "Your Blue Badge application has been approved",
                    body: "Your Blue Badge will arrive within 10 working days.",
                    date: now.addingTimeInterval(-2 * oneDay),
                    status: "READ",
                    messageTitle: "Blue Badge approved",
                    messageBody: "We're pleased to tell you that your Blue Badge application has been approved. Your badge will be posted to your registered address and should arrive within 10 working days.\n\nIf it has not arrived after 15 working days, contact your local council."
                ),
                // Read — short, no alternate content
                .init(
                    id: "4",
                    title: "Tax credits payment of £342.00 has been processed",
                    body: "Your payment will reach your account within 3 working days.",
                    date: now.addingTimeInterval(-3 * oneDay),
                    status: "READ",
                    messageTitle: nil,
                    messageBody: nil
                ),
                // Unread — slightly longer title to test ellipsis
                .init(
                    id: "6",
                    title: "Reminder: your passport expires in 6 months — renew before travelling to the EU",
                    body: "Some EU countries require your passport to be valid for at least 6 months. Renew now to avoid disruption.",
                    date: now.addingTimeInterval(-5 * oneDay),
                    status: "UNREAD",
                    messageTitle: nil,
                    messageBody: nil
                ),
                // Read — short
                .init(
                    id: "7",
                    title: "Your driving licence has been updated",
                    body: "Your updated photocard driving licence is being printed and will arrive within 3 weeks.",
                    date: now.addingTimeInterval(-6 * oneDay),
                    status: "READ",
                    messageTitle: nil,
                    messageBody: nil
                ),
            ]

            let older: [Notification] = [
                .init(
                    id: "9",
                    title: "Your child benefit payment of £102.40 has been processed",
                    body: "This payment covers the 4-week period ending 14 June 2026.",
                    date: now.addingTimeInterval(-14 * oneDay),
                    status: "READ",
                    messageTitle: nil,
                    messageBody: nil
                ),
                .init(
                    id: "10",
                    title: "Electoral register: confirm your details before 30 April 2027",
                    body: "Your local council requires you to _confirm or update_ your details on the electoral register. [Test link](https://gov.uk)",
                    date: now.addingTimeInterval(-21 * oneDay),
                    status: "READ",
                    messageTitle: nil,
                    messageBody: nil
                ),
                .init(
                    id: "11",
                    title: "Your State Pension forecast has been updated",
                    body: "Sign in to your account to view your updated State Pension forecast and full National Insurance record.",
                    date: now.addingTimeInterval(-28 * oneDay),
                    status: "READ",
                    messageTitle: nil,
                    messageBody: nil
                ),
            ]

            return NotificationGroups(recent: recent, older: older)
        }()
    }
    // swiftlint:enable line_length

    enum State: Equatable {
        case loading, empty, loaded(notifications: NotificationGroups), error, noInternet
    }

    struct NotificationGroups: Equatable {
        let recent: [Notification]
        let older: [Notification]
    }

    class DateProvider {
        open var currentDate: Date {
            Date()
        }
    }

    @Published public private(set) var state: State = .loading

    private let actions: Actions
    private let notificationCentreService: NotificationCentreServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let dateProvider: DateProvider

    init(
        actions: Actions,
        notificationCentreService: NotificationCentreServiceInterface,
        analyticsService: AnalyticsServiceInterface,
        dateProvider: DateProvider = .init()) {
            self.actions = actions
            self.notificationCentreService = notificationCentreService
            self.analyticsService = analyticsService
            self.dateProvider = dateProvider
        }

    func onViewAppear() {
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

            notificationCentreService.fetchNotifications { [weak self] res in
                Task {
                    guard let self else { return }
                    switch res {
                    case .success(let notifications):
                        if notifications.isEmpty {
                            await self.changeState(state: .empty)
                        } else {
                            let sorted = notifications.sorted {
                                $0.date > $1.date
                            }

                            let sevenDaysBack = self.dateProvider
                                .currentDate.addingTimeInterval(-7 * 24.0 * 60.0 * 60.0)

                            let buckets = NotificationGroups(
                                recent: sorted.filter {
                                    $0.date >= sevenDaysBack
                                }, older: sorted.filter {
                                    $0.date < sevenDaysBack
                                })


                            await self.changeState(state: .loaded(notifications: buckets))
                        }
                    case .failure(let error):
                        switch error {
                        case .networkUnavailable:
                            await self.changeState(state: .noInternet)
                        default:
                            await self.changeState(state: .error)
                        }
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
