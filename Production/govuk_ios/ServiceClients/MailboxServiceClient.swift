import Foundation

enum MailboxError: Error {
    case networkUnavailable
    case apiUnavailable
    case decodingError
    case notFound
    case noMailbox
}

/// Maps Client Access API status codes to `MailboxError`.
///
/// The API answers 403 both for a bad token and for a citizen with no
/// mailbox. `APIServiceClient` refreshes the token and retries once on a
/// 403, so a 403 that reaches this handler is treated as "no mailbox".
struct MailboxResponseHandler: ResponseHandler {
    func handleStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        case 403:
            return MailboxError.noMailbox
        case 404:
            return MailboxError.notFound
        default:
            return MailboxError.apiUnavailable
        }
    }
}

protocol MailboxServiceClientInterface {
    func fetchMessages() async -> Result<MailboxMessagesResponse, MailboxError>
    func fetchMessage(id: String) async -> Result<MailboxMessage, MailboxError>
    func markAsRead(id: String) async -> Result<Void, MailboxError>
    func markAsUnread(id: String) async -> Result<Void, MailboxError>
    func deleteMessage(id: String) async -> Result<Void, MailboxError>
}

class MailboxServiceClient: MailboxServiceClientInterface {
    private let apiServiceClient: APIServiceClientInterface

    init(apiServiceClient: APIServiceClientInterface) {
        self.apiServiceClient = apiServiceClient
    }

    func fetchMessages() async -> Result<MailboxMessagesResponse, MailboxError> {
        await performRequest(.mailboxMessages())
    }

    func fetchMessage(id: String) async -> Result<MailboxMessage, MailboxError> {
        await performRequest(.mailboxMessage(id: id))
    }

    func markAsRead(id: String) async -> Result<Void, MailboxError> {
        let readAt = ISO8601DateFormatter().string(from: Date())
        return await performVoidRequest(.markMessageRead(id: id, readAt: readAt))
    }

    func markAsUnread(id: String) async -> Result<Void, MailboxError> {
        await performVoidRequest(.markMessageUnread(id: id))
    }

    func deleteMessage(id: String) async -> Result<Void, MailboxError> {
        await performVoidRequest(.deleteMailboxMessage(id: id))
    }

    private func performRequest<T: Decodable>(
        _ request: GOVRequest
    ) async -> Result<T, MailboxError> {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: request,
                completion: { result in
                    continuation.resume(
                        returning: self.mapResult(result)
                    )
                }
            )
        }
    }

    private func performVoidRequest(
        _ request: GOVRequest
    ) async -> Result<Void, MailboxError> {
        await withCheckedContinuation { continuation in
            apiServiceClient.send(
                request: request,
                completion: { result in
                    continuation.resume(
                        returning: result
                            .map { _ in () }
                            .mapError { self.mapError($0) }
                    )
                }
            )
        }
    }

    private func mapResult<T: Decodable>(
        _ result: NetworkResult<Data>
    ) -> Result<T, MailboxError> {
        result.mapError { error in
            mapError(error)
        }.flatMap { data in
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded)
            } catch {
                return .failure(.decodingError)
            }
        }
    }

    private func mapError(_ error: Error) -> MailboxError {
        if let mailboxError = error as? MailboxError {
            return mailboxError
        }
        let nsError = error as NSError
        if nsError.code == NSURLErrorNotConnectedToInternet {
            return .networkUnavailable
        }
        return .apiUnavailable
    }
}
