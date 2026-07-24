import Foundation

protocol MailboxServiceInterface {
    var isEnabled: Bool { get }
    var unopenedCount: Int { get }
    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
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
    func updateActionStatus(
        messageId: String,
        status: ActionStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

// swiftlint:disable:next type_body_length
final class MailboxService: MailboxServiceInterface {
    private let apiClient: MailboxServiceClientInterface
    private let tokenIssuer: TestTokenIssuer
    private let testAuthSystemSub: String

    private var cachedMessages: [MailboxMessage] = []

    var isEnabled: Bool { true }

    var unopenedCount: Int {
        cachedMessages.filter { $0.status == .unopened }.count
    }

    init(apiClient: MailboxServiceClientInterface = MailboxServiceClient(),
         tokenIssuer: TestTokenIssuer = TestTokenIssuer(),
         testAuthSystemSub: String = "test-citizen-001") {
        self.apiClient = apiClient
        self.tokenIssuer = tokenIssuer
        self.testAuthSystemSub = testAuthSystemSub
    }

    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
    ) {
        tokenIssuer.generateToken(authSystemSub: testAuthSystemSub) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                self.apiClient.listMessages(token: token, limit: nil, nextToken: nil) { result in
                    switch result {
                    case .success(let response):
                        let messages = response.messages.map { $0.toMailboxMessage() }
                        self.cachedMessages = messages
                        completion(.success(messages))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func markAsOpened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        tokenIssuer.generateToken(authSystemSub: testAuthSystemSub) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                self.apiClient.markAsRead(token: token, messageId: messageId, readAt: Date()) { result in
                    switch result {
                    case .success:
                        if let index = self.cachedMessages.firstIndex(where: { $0.id == messageId }) {
                            self.cachedMessages[index].status = .opened
                        }
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteMessage(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        tokenIssuer.generateToken(authSystemSub: testAuthSystemSub) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                self.apiClient.deleteMessage(token: token, messageId: messageId) { result in
                    switch result {
                    case .success:
                        self.cachedMessages.removeAll { $0.id == messageId }
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func markAsUnopened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        tokenIssuer.generateToken(authSystemSub: testAuthSystemSub) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                self.apiClient.markAsUnread(token: token, messageId: messageId) { result in
                    switch result {
                    case .success:
                        if let index = self.cachedMessages.firstIndex(where: { $0.id == messageId }) {
                            self.cachedMessages[index].status = .unopened
                        }
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateActionStatus(
        messageId: String,
        status: ActionStatus,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if let index = cachedMessages.firstIndex(where: { $0.id == messageId }) {
            cachedMessages[index].actionStatus = status
        }
        completion(.success(()))
    }

}
