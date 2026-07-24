import Foundation

// MARK: - Message Models

struct MessageListItem: Codable, Identifiable {
    let messageId: String
    let mailboxId: String
    let receivedAt: String
    let subject: String
    let sender: String

    var id: String { messageId }

    var receivedDate: Date? {
        ISO8601DateFormatter().date(from: receivedAt)
    }

    enum CodingKeys: String, CodingKey {
        case messageId
        case mailboxId
        case receivedAt
        case subject
        case sender = "senderDept"  // API returns "senderDept", map to "sender"
    }
}

struct MessageDetail: Codable, Identifiable {
    let messageId: String
    let mailboxId: String
    let receivedAt: String
    let subject: String
    let sender: String
    let body: String

    // Future fields (not yet implemented in backend)
    let serviceName: String?
    let messageType: String?
    let primaryAction: APIMessageAction?
    let deadline: String?
    let secondaryAction: APIMessageAction?

    var id: String { messageId }

    var receivedDate: Date? {
        ISO8601DateFormatter().date(from: receivedAt)
    }

    var deadlineDate: Date? {
        guard let deadline = deadline else { return nil }
        return ISO8601DateFormatter().date(from: deadline)
    }

    enum CodingKeys: String, CodingKey {
        case messageId
        case mailboxId
        case receivedAt
        case subject
        case sender = "senderDept"  // API returns "senderDept", map to "sender"
        case body
        case serviceName
        case messageType
        case primaryAction
        case deadline
        case secondaryAction
    }
}

struct APIMessageAction: Codable {
    let text: String
    let link: String?
}

struct ListMessagesResponse: Codable {
    let messages: [MessageListItem]
    let nextToken: String?
}

// MARK: - Consent Models

struct GrantConsentRequest: Codable {
    let departmentId: String
    let departmentPersonId: String
}

struct GrantConsentResponse: Codable {
    let mailboxId: String
    let departmentId: String
    let departmentPersonId: String
    let consentedAt: String
}

// MARK: - Mailbox Creation Models

struct CreateMailboxResponse: Codable {
    let mailboxId: String
    let authSystemSub: String
    let createdAt: String
}

// MARK: - Update Message Models

struct UpdateMessageRequest: Codable {
    let readAt: String?
    let archived: Bool?
}

struct UpdateMessageResponse: Codable {
    let success: Bool
}

// MARK: - Error Models

struct APIErrorResponse: Codable {
    let error: String
}

// MARK: - Mailbox Errors

enum MailboxError: Error {
    case networkUnavailable
    case apiUnavailable
    case authenticationFailed
    case notFound
    case parsingError
    case serverError(Int)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .networkUnavailable:
            return "No internet connection"
        case .apiUnavailable:
            return "Service temporarily unavailable"
        case .authenticationFailed:
            return "Authentication failed. Please sign in again."
        case .notFound:
            return "Message not found"
        case .parsingError:
            return "Unable to read response"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Adapter to UI Models

extension MessageListItem {
    func toMailboxMessage() -> MailboxMessage {
        MailboxMessage(
            id: messageId,
            sender: senderToMessageSender(sender),
            subject: subject,
            body: "",
            receivedDate: receivedDate ?? Date(),
            status: .unopened,
            previewText: subject,
            actions: [],
            actionStatus: nil
        )
    }

    private func senderToMessageSender(_ senderName: String) -> MessageSender {
        let normalized = senderName.lowercased()
        if normalized.contains("dvla") || normalized.contains("vehicle licensing") {
            return .dvla
        } else if normalized.contains("hmrc") || normalized.contains("revenue") {
            return .hmrc
        } else if normalized.contains("dwp") || normalized.contains("work and pensions") {
            return .dwp
        } else if normalized.contains("council") {
            return .manchesterCouncil
        } else {
            return .govuk
        }
    }
}

extension MessageDetail {
    func toMailboxMessage() -> MailboxMessage {
        // Use fully qualified name to avoid ambiguity with APIMessageAction
        var uiActions: [MessageAction] = []

        if let primary = primaryAction, let url = URL(string: primary.link ?? "") {
            uiActions.append(MessageAction.openURL(title: primary.text, url: url))
        }

        if let secondary = secondaryAction, let url = URL(string: secondary.link ?? "") {
            uiActions.append(MessageAction.openURL(title: secondary.text, url: url))
        }

        let actionStatus: ActionStatus? = {
            guard let type = messageType?.lowercased() else { return nil }
            if type.contains("action") {
                return .actionRequired
            } else if type.contains("payment") {
                return .paymentPending
            }
            return nil
        }()

        return MailboxMessage(
            id: messageId,
            sender: senderToMessageSender(sender),
            subject: subject,
            body: body,
            receivedDate: receivedDate ?? Date(),
            status: .opened,
            previewText: String(body.prefix(100)),
            actions: uiActions,
            actionStatus: actionStatus
        )
    }

    private func senderToMessageSender(_ senderName: String) -> MessageSender {
        let normalized = senderName.lowercased()
        if normalized.contains("dvla") || normalized.contains("vehicle licensing") {
            return .dvla
        } else if normalized.contains("hmrc") || normalized.contains("revenue") {
            return .hmrc
        } else if normalized.contains("dwp") || normalized.contains("work and pensions") {
            return .dwp
        } else if normalized.contains("council") {
            return .manchesterCouncil
        } else {
            return .govuk
        }
    }
}
