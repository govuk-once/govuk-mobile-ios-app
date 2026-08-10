import Foundation

@testable import govuk_ios

class MockMailboxService: MailboxServiceInterface {
    var isEnabled: Bool = true
    var unopenedCount: Int = 0
    var onMessagesUpdated: (([MailboxMessage]) -> Void)?

    var _fetchMessagesCallCount = 0
    var _stubbedFetchMessagesResult: Result<[MailboxMessage], Error>?
    func fetchMessages(
        completion: @escaping (Result<[MailboxMessage], Error>) -> Void
    ) {
        _fetchMessagesCallCount += 1
        if let result = _stubbedFetchMessagesResult {
            completion(result)
        }
    }

    var _stubbedFetchMessageResult: Result<MailboxMessage, Error>?
    func fetchMessage(
        messageId: String,
        completion: @escaping (Result<MailboxMessage, Error>) -> Void
    ) {
        if let result = _stubbedFetchMessageResult {
            completion(result)
        }
    }

    var _stubbedMarkAsOpenedResult: Result<Void, Error> = .success(())
    func markAsOpened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completion(_stubbedMarkAsOpenedResult)
    }

    var _stubbedDeleteMessageResult: Result<Void, Error> = .success(())
    func deleteMessage(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completion(_stubbedDeleteMessageResult)
    }

    var _stubbedMarkAsUnopenedResult: Result<Void, Error> = .success(())
    func markAsUnopened(
        messageId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        completion(_stubbedMarkAsUnopenedResult)
    }
}
