import Foundation
import Combine

@MainActor
class MailboxViewModel: ObservableObject {
    @Published var messages: [MessageListItem] = []
    @Published var isLoading = false
    @Published var error: MailboxError?
    @Published var nextToken: String?
    @Published var hasMoreMessages = false

    private let serviceClient: MailboxServiceClientInterface
    private let token: String
    private var cancellables = Set<AnyCancellable>()

    init(serviceClient: MailboxServiceClientInterface,
         token: String) {
        self.serviceClient = serviceClient
        self.token = token
    }

    func loadMessages() {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        serviceClient.listMessages(token: token, limit: 20, nextToken: nil) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.messages = response.messages
                    self.nextToken = response.nextToken
                    self.hasMoreMessages = response.nextToken != nil
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }

    func loadMoreMessages() {
        guard !isLoading, let nextToken = nextToken else { return }

        isLoading = true

        serviceClient.listMessages(token: token, limit: 20, nextToken: nextToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.messages.append(contentsOf: response.messages)
                    self.nextToken = response.nextToken
                    self.hasMoreMessages = response.nextToken != nil
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }

    func markAsRead(messageId: String) {
        serviceClient.markAsRead(token: token, messageId: messageId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    // Optionally update local state
                    break
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }

    func deleteMessage(messageId: String) {
        serviceClient.deleteMessage(token: token, messageId: messageId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.messages.removeAll { $0.messageId == messageId }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }

    func archiveMessage(messageId: String) {
        serviceClient.archiveMessage(token: token, messageId: messageId, archived: true) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.messages.removeAll { $0.messageId == messageId }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

@MainActor
class MessageDetailViewModel: ObservableObject {
    @Published var message: MessageDetail?
    @Published var isLoading = false
    @Published var error: MailboxError?

    private let serviceClient: MailboxServiceClientInterface
    private let token: String
    private let messageId: String

    init(serviceClient: MailboxServiceClientInterface,
         token: String,
         messageId: String) {
        self.serviceClient = serviceClient
        self.token = token
        self.messageId = messageId
    }

    func loadMessage() {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        serviceClient.getMessage(token: token, messageId: messageId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let message):
                    self.message = message
                    // Mark as read when viewing
                    self.markAsRead()
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }

    private func markAsRead() {
        serviceClient.markAsRead(token: token, messageId: messageId) { _ in
            // Silent marking - don't show error to user
        }
    }

    func deleteMessage(completion: @escaping (Bool) -> Void) {
        serviceClient.deleteMessage(token: token, messageId: messageId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.error = error
                    completion(false)
                }
            }
        }
    }

    func archiveMessage(completion: @escaping (Bool) -> Void) {
        serviceClient.archiveMessage(token: token, messageId: messageId, archived: true) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.error = error
                    completion(false)
                }
            }
        }
    }
}
