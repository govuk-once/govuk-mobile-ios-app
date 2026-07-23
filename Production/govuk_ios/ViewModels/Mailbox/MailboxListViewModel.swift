import Foundation
import SwiftUI
import GovKit

class MailboxListViewModel: ObservableObject {
    private let mailboxService: MailboxServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    private let messageSelectedAction: (MailboxMessage) -> Void

    @Published var messages: [MailboxMessage] = []
    @Published var isLoading: Bool = false
    @Published var selectedSenderFilter: MessageSender?

    var filteredMessages: [MailboxMessage] {
        guard let filter = selectedSenderFilter else {
            return messages
        }
        return messages.filter { $0.sender == filter }
    }

    var hasMessages: Bool {
        !filteredMessages.isEmpty
    }

    init(mailboxService: MailboxServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         messageSelectedAction: @escaping (MailboxMessage) -> Void) {
        self.mailboxService = mailboxService
        self.analyticsService = analyticsService
        self.messageSelectedAction = messageSelectedAction
    }

    func loadMessages() {
        isLoading = true
        mailboxService.fetchMessages { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let messages):
                    self?.messages = messages
                case .failure:
                    break
                }
            }
        }
    }

    func selectMessage(_ message: MailboxMessage) {
        mailboxService.markAsOpened(messageId: message.id) { [weak self] _ in
            DispatchQueue.main.async {
                if let index = self?.messages.firstIndex(
                    where: { $0.id == message.id }
                ) {
                    self?.messages[index].status = .opened
                }
                self?.messageSelectedAction(message)
            }
        }
    }

    func markAsUnopened(_ message: MailboxMessage) {
        mailboxService.markAsUnopened(messageId: message.id) { [weak self] _ in
            DispatchQueue.main.async {
                if let index = self?.messages.firstIndex(
                    where: { $0.id == message.id }
                ) {
                    self?.messages[index].status = .unopened
                }
            }
        }
    }

    func deleteMessage(_ message: MailboxMessage) {
        mailboxService.deleteMessage(messageId: message.id) { [weak self] _ in
            DispatchQueue.main.async {
                self?.messages.removeAll { $0.id == message.id }
            }
        }
    }

    func setFilter(_ sender: MessageSender?) {
        selectedSenderFilter = sender
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }
}
