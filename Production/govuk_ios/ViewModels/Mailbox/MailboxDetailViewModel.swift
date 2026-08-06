import Foundation
import UIKit
import GovKit

class MailboxDetailViewModel: ObservableObject {
    private let message: MailboxMessage
    private let mailboxService: MailboxServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let actionHandler: (MessageAction) -> Void
    private let deleteHandler: (MailboxMessage) -> Void
    private let markUnopenedHandler: (MailboxMessage) -> Void

    @Published var bodyText: String = ""
    @Published var actions: [MessageAction] = []
    @Published var isLoadingBody: Bool = false

    var senderName: String { message.senderDisplayName }
    var subject: String { message.subject }
    var senderColor: UIColor { message.senderColor }
    var senderLetter: String { message.senderLetter }

    var formattedDate: String {
        guard let date = message.receivedDate else {
            return message.receivedAt
        }
        return Self.dateFormatter.string(from: date)
    }

    init(message: MailboxMessage,
         mailboxService: MailboxServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         actionHandler: @escaping (MessageAction) -> Void,
         deleteHandler: @escaping (MailboxMessage) -> Void,
         markUnopenedHandler: @escaping (MailboxMessage) -> Void) {
        self.message = message
        self.mailboxService = mailboxService
        self.analyticsService = analyticsService
        self.actionHandler = actionHandler
        self.deleteHandler = deleteHandler
        self.markUnopenedHandler = markUnopenedHandler
    }

    func loadFullMessage() {
        isLoadingBody = true
        mailboxService.fetchMessage(messageId: message.messageId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingBody = false
                switch result {
                case .success(let fullMessage):
                    self?.bodyText = fullMessage.displayBody
                    self?.actions = fullMessage.parsedActions
                case .failure:
                    self?.bodyText = ""
                }
            }
        }
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
