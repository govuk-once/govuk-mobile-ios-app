import Foundation

protocol MailboxServiceInterface {
    var isEnabled: Bool { get }
    var unopenedCount: Int { get }
    var onMessagesUpdated: (([MailboxMessage]) -> Void)? { get set }
    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
    )
    func fetchMessage(
        messageId: String,
        completion: @escaping (Result<MailboxMessage, Error>) -> Void
    )
    func markAsOpened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteMessage(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func markAsUnopened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class MailboxService: MailboxServiceInterface {
    private let serviceClient: MailboxServiceClientInterface
    private let tokenProvider: MailboxTokenProvider
    private let userDefaults: UserDefaults
    private let cacheLock = NSLock()

    private static let markedUnopenedKey = "govuk_mailbox_marked_unopened"

    var isEnabled: Bool { true }
    var onMessagesUpdated: (([MailboxMessage]) -> Void)?

    private var cachedMessages: [MailboxMessage] = []

    var unopenedCount: Int {
        cachedMessagesSnapshot().filter {
            $0.isUnopened || isMarkedUnopened($0.messageId)
        }.count
    }

    init(serviceClient: MailboxServiceClientInterface,
         tokenProvider: MailboxTokenProvider,
         userDefaults: UserDefaults = .standard) {
        self.serviceClient = serviceClient
        self.tokenProvider = tokenProvider
        self.userDefaults = userDefaults
    }

    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
    ) {
        Task {
            let result = await serviceClient.fetchMessages()
            switch result {
            case .success(let response):
                var messages = response.messages
                self.applyLocalUnopenedState(&messages)
                self.updateCachedMessages(messages)
                completion(.success(messages))

                await self.enrichWithBodies()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func enrichWithBodies() async {
        var enrichedMessages = cachedMessagesSnapshot()

        for index in enrichedMessages.indices {
            guard enrichedMessages[index].body == nil else { continue }
            let result = await serviceClient.fetchMessage(
                id: enrichedMessages[index].messageId
            )
            if case .success(let full) = result {
                enrichedMessages[index] = MailboxMessage(
                    messageId: full.messageId,
                    mailboxId: full.mailboxId,
                    receivedAt: full.receivedAt,
                    subject: full.subject,
                    senderDept: full.senderDept,
                    body: full.body,
                    readAt: enrichedMessages[index].readAt
                )
            }
        }

        mergeEnrichedMessages(enrichedMessages)
        let updated = cachedMessagesSnapshot()
        DispatchQueue.main.async {
            self.onMessagesUpdated?(updated)
        }
    }

    func fetchMessage(
        messageId: String,
        completion: @escaping (Result<MailboxMessage, Error>) -> Void
    ) {
        Task {
            let result = await serviceClient.fetchMessage(id: messageId)
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    completion(.success(message))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func markAsOpened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        removeFromMarkedUnopened(messageId)

        Task {
            let result = await serviceClient.markAsRead(id: messageId)
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.updateCachedMessage(
                        messageId: messageId,
                        readAt: ISO8601DateFormatter().string(from: Date())
                    )
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteMessage(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        removeFromMarkedUnopened(messageId)

        Task {
            let result = await serviceClient.deleteMessage(id: messageId)
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.removeCachedMessage(messageId)
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func markAsUnopened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        addToMarkedUnopened(messageId)

        updateCachedMessage(messageId: messageId, readAt: nil)
        completion(.success(()))
    }

    // MARK: - Local "marked as unopened" persistence

    private func markedUnopenedIds() -> Set<String> {
        let array = userDefaults.stringArray(
            forKey: Self.markedUnopenedKey
        ) ?? []
        return Set(array)
    }

    private func isMarkedUnopened(_ messageId: String) -> Bool {
        markedUnopenedIds().contains(messageId)
    }

    private func addToMarkedUnopened(_ messageId: String) {
        var ids = markedUnopenedIds()
        ids.insert(messageId)
        userDefaults.set(Array(ids), forKey: Self.markedUnopenedKey)
    }

    private func removeFromMarkedUnopened(_ messageId: String) {
        var ids = markedUnopenedIds()
        ids.remove(messageId)
        userDefaults.set(Array(ids), forKey: Self.markedUnopenedKey)
    }

    private func applyLocalUnopenedState(_ messages: inout [MailboxMessage]) {
        let ids = markedUnopenedIds()
        for index in messages.indices where ids.contains(messages[index].messageId) {
            messages[index].readAt = nil
        }
    }

    private func cachedMessagesSnapshot() -> [MailboxMessage] {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return cachedMessages
    }

    private func updateCachedMessages(_ messages: [MailboxMessage]) {
        cacheLock.lock()
        cachedMessages = messages
        cacheLock.unlock()
    }

    private func updateCachedMessage(messageId: String, readAt: String?) {
        cacheLock.lock()
        if let index = cachedMessages.firstIndex(where: { $0.messageId == messageId }) {
            cachedMessages[index].readAt = readAt
        }
        cacheLock.unlock()
    }

    private func removeCachedMessage(_ messageId: String) {
        cacheLock.lock()
        cachedMessages.removeAll { $0.messageId == messageId }
        cacheLock.unlock()
    }

    private func mergeEnrichedMessages(_ enrichedMessages: [MailboxMessage]) {
        cacheLock.lock()
        let currentReadAtById = Dictionary(
            uniqueKeysWithValues: cachedMessages.map { ($0.messageId, $0.readAt) }
        )
        cachedMessages = enrichedMessages.map { message in
            var merged = message
            if let readAt = currentReadAtById[message.messageId] {
                merged.readAt = readAt
            }
            return merged
        }
        cacheLock.unlock()
    }
}
