import Foundation
import SwiftUI
import GovKit

class MailboxListViewModel: ObservableObject {
    private var mailboxService: MailboxServiceInterface
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

        self.mailboxService.onMessagesUpdated = { [weak self] updated in
            DispatchQueue.main.async {
                self?.messages = updated
            }
        }
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

    @MainActor
    func refreshMessages() async {
        loadMessages()
        try? await Task.sleep(nanoseconds: 1_200_000_000)
    }

    func selectMessage(_ message: MailboxMessage) {
        messageSelectedAction(message)

        if message.isUnopened {
            if let index = messages.firstIndex(
                where: { $0.messageId == message.messageId }
            ) {
                messages[index].readAt =
                    ISO8601DateFormatter().string(from: Date())
            }
            mailboxService.markAsOpened(messageId: message.messageId) { _ in }
        }
    }

    func markAsUnopened(_ message: MailboxMessage) {
        mailboxService.markAsUnopened(messageId: message.messageId) { [weak self] _ in
            DispatchQueue.main.async {
                if let index = self?.messages.firstIndex(
                    where: { $0.messageId == message.messageId }
                ) {
                    self?.messages[index].readAt = nil
                }
            }
        }
    }

    func deleteMessage(_ message: MailboxMessage) {
        mailboxService.deleteMessage(messageId: message.messageId) { [weak self] _ in
            DispatchQueue.main.async {
                self?.messages.removeAll { $0.messageId == message.messageId }
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
