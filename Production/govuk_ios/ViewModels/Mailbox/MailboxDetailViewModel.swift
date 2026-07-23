import Foundation
import UIKit
import GovKit

class MailboxDetailViewModel: ObservableObject {
    let message: MailboxMessage
    private let analyticsService: AnalyticsServiceInterface
    private let actionHandler: (MessageAction) -> Void
    private let deleteHandler: (MailboxMessage) -> Void
    private let markUnopenedHandler: (MailboxMessage) -> Void

    var senderName: String { message.sender.rawValue }
    var subject: String { message.subject }
    var body: String { message.body }
    var senderColor: UIColor { message.sender.iconColor }
    var senderLetter: String { message.sender.iconLetter }
    var actions: [MessageAction] { message.actions }
    var actionStatus: ActionStatus? { message.actionStatus }

    var formattedDate: String {
        Self.dateFormatter.string(from: message.receivedDate)
    }

    init(message: MailboxMessage,
         analyticsService: AnalyticsServiceInterface,
         actionHandler: @escaping (MessageAction) -> Void,
         deleteHandler: @escaping (MailboxMessage) -> Void,
         markUnopenedHandler: @escaping (MailboxMessage) -> Void) {
        self.message = message
        self.analyticsService = analyticsService
        self.actionHandler = actionHandler
        self.deleteHandler = deleteHandler
        self.markUnopenedHandler = markUnopenedHandler
    }

    func performAction(_ action: MessageAction) {
        actionHandler(action)
    }

    func deleteMessage() {
        deleteHandler(message)
    }

    func markAsUnopened() {
        markUnopenedHandler(message)
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
}
