import Foundation

protocol MailboxServiceClientInterface {
    func createMailbox(token: String,
                      completion: @escaping (Result<CreateMailboxResponse, MailboxError>) -> Void)

    func listMessages(token: String,
                     limit: Int?,
                     nextToken: String?,
                     completion: @escaping (Result<ListMessagesResponse, MailboxError>) -> Void)

    func getMessage(token: String,
                   messageId: String,
                   completion: @escaping (Result<MessageDetail, MailboxError>) -> Void)

    func markAsRead(token: String,
                   messageId: String,
                   readAt: Date,
                   completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void)

    func markAsUnread(token: String,
                     messageId: String,
                     completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void)

    func archiveMessage(token: String,
                       messageId: String,
                       archived: Bool,
                       completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void)

    func deleteMessage(token: String,
                      messageId: String,
                      completion: @escaping (Result<Void, MailboxError>) -> Void)

    func grantConsent(token: String,
                     departmentId: String,
                     departmentPersonId: String,
                     completion: @escaping (Result<GrantConsentResponse, MailboxError>) -> Void)
}

class MailboxServiceClient: MailboxServiceClientInterface {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: String = "https://l8yqwba7pd.execute-api.eu-west-2.amazonaws.com/prod",
         session: URLSession = .shared) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid mailbox base URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
    }

    // MARK: - Create Mailbox

    func createMailbox(token: String,
                      completion: @escaping (Result<CreateMailboxResponse, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/users")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        performRequest(request, completion: completion)
    }

    // MARK: - List Messages

    func listMessages(token: String,
                     limit: Int? = nil,
                     nextToken: String? = nil,
                     completion: @escaping (Result<ListMessagesResponse, MailboxError>) -> Void) {
        var components = URLComponents(url: baseURL.appendingPathComponent("/messages"), resolvingAgainstBaseURL: false)!

        var queryItems: [URLQueryItem] = []
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let nextToken = nextToken {
            queryItems.append(URLQueryItem(name: "nextToken", value: nextToken))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            completion(.failure(.unknownError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        performRequest(request, completion: completion)
    }

    // MARK: - Get Message

    func getMessage(token: String,
                   messageId: String,
                   completion: @escaping (Result<MessageDetail, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/messages/\(messageId)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        performRequest(request, completion: completion)
    }

    // MARK: - Mark as Read

    func markAsRead(token: String,
                   messageId: String,
                   readAt: Date = Date(),
                   completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/messages/\(messageId)")

        let body = UpdateMessageRequest(
            readAt: ISO8601DateFormatter().string(from: readAt),
            archived: nil
        )

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        performRequest(request, completion: completion)
    }

    // MARK: - Mark as Unread

    func markAsUnread(token: String,
                     messageId: String,
                     completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/messages/\(messageId)")

        // Use null for readAt to mark as unread
        let body: [String: Any?] = ["readAt": nil]

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        performRequest(request, completion: completion)
    }

    // MARK: - Archive Message

    func archiveMessage(token: String,
                       messageId: String,
                       archived: Bool,
                       completion: @escaping (Result<UpdateMessageResponse, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/messages/\(messageId)")

        let body = UpdateMessageRequest(
            readAt: nil,
            archived: archived
        )

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        performRequest(request, completion: completion)
    }

    // MARK: - Delete Message

    func deleteMessage(token: String,
                      messageId: String,
                      completion: @escaping (Result<Void, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/messages/\(messageId)")

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        session.dataTask(with: request) { _, response, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.networkUnavailable))
                } else {
                    completion(.failure(.apiUnavailable))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknownError))
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            case 401:
                completion(.failure(.authenticationFailed))
            case 404:
                completion(.failure(.notFound))
            default:
                completion(.failure(.serverError(httpResponse.statusCode)))
            }
        }.resume()
    }

    // MARK: - Grant Consent

    func grantConsent(token: String,
                     departmentId: String,
                     departmentPersonId: String,
                     completion: @escaping (Result<GrantConsentResponse, MailboxError>) -> Void) {
        let url = baseURL.appendingPathComponent("/consents")

        let body = GrantConsentRequest(
            departmentId: departmentId,
            departmentPersonId: departmentPersonId
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        performRequest(request, completion: completion)
    }

    // MARK: - Private Helpers

    private func performRequest<T: Decodable>(_ request: URLRequest,
                                              completion: @escaping (Result<T, MailboxError>) -> Void) {
        print("📡 Mailbox API Request: \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                let nsError = error as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.networkUnavailable))
                } else {
                    completion(.failure(.apiUnavailable))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                completion(.failure(.unknownError))
                return
            }

            print("📡 Response: \(httpResponse.statusCode)")

            guard let data = data else {
                print("❌ No data received")
                completion(.failure(.unknownError))
                return
            }

            if let responseBody = String(data: data, encoding: .utf8) {
                print("📦 Response body: \(responseBody)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    print("✅ Successfully decoded response")
                    completion(.success(result))
                } catch {
                    print("❌ Parsing error: \(error)")
                    completion(.failure(.parsingError))
                }
            case 401:
                print("❌ Authentication failed (401)")
                completion(.failure(.authenticationFailed))
            case 404:
                print("❌ Not found (404)")
                completion(.failure(.notFound))
            default:
                print("❌ Server error: \(httpResponse.statusCode)")
                completion(.failure(.serverError(httpResponse.statusCode)))
            }
        }.resume()
    }
}
