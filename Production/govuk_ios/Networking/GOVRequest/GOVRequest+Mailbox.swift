import Foundation

struct MarkReadBody: Codable {
    let readAt: String?
}

extension GOVRequest {
    private static let messagesPath = "/messages"
    private static var jsonHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static func mailboxMessages(
        limit: Int? = nil,
        nextToken: String? = nil
    ) -> GOVRequest {
        var queryParameters: [String: String?]?
        if limit != nil || nextToken != nil {
            var params: [String: String?] = [:]
            if let limit { params["limit"] = String(limit) }
            if let nextToken { params["nextToken"] = nextToken }
            queryParameters = params
        }
        return GOVRequest(
            urlPath: messagesPath,
            method: .get,
            body: nil,
            queryParameters: queryParameters,
            additionalHeaders: jsonHeaders,
            requiresAuthentication: true
        )
    }

    static func mailboxMessage(id: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(messagesPath)/\(id)",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: jsonHeaders,
            requiresAuthentication: true
        )
    }

    static func markMessageRead(id: String, readAt: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(messagesPath)/\(id)",
            method: .patch,
            body: MarkReadBody(readAt: readAt),
            queryParameters: nil,
            additionalHeaders: jsonHeaders,
            requiresAuthentication: true
        )
    }

    static func markMessageUnread(id: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(messagesPath)/\(id)",
            method: .patch,
            body: MarkReadBody(readAt: nil),
            queryParameters: nil,
            additionalHeaders: jsonHeaders,
            requiresAuthentication: true
        )
    }

    static func deleteMailboxMessage(id: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(messagesPath)/\(id)",
            method: .delete,
            body: nil,
            queryParameters: nil,
            additionalHeaders: jsonHeaders,
            requiresAuthentication: true
        )
    }

    static func mailboxToken(authSystemSub: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/v1/token",
            method: .post,
            body: MailboxTokenRequestBody(authSystemSub: authSystemSub),
            queryParameters: nil,
            additionalHeaders: jsonHeaders,
            requiresAuthentication: false
        )
    }
}

struct MailboxTokenRequestBody: Codable {
    let authSystemSub: String
}
