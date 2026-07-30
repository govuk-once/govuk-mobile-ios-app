import Foundation
import UIKit

enum MessageSender: String, CaseIterable {
    case dvla = "dvla"
    case hmrc = "hmrc"
    case govuk = "govuk"
    case dwp = "dwp"
    case hmpo = "hmpo"
    case pilotDepartment = "pilot-department"

    var displayName: String {
        switch self {
        case .dvla: return "DVLA"
        case .hmrc: return "HMRC"
        case .govuk: return "GOV.UK"
        case .dwp: return "DWP"
        case .hmpo: return "HMPO"
        case .pilotDepartment: return "Pilot Department"
        }
    }

    var iconColor: UIColor {
        switch self {
        case .dvla:
            return UIColor(red: 0.0, green: 0.45, blue: 0.74, alpha: 1.0)
        case .hmrc:
            return UIColor(red: 0.0, green: 0.51, blue: 0.35, alpha: 1.0)
        case .govuk:
            return UIColor(red: 0.11, green: 0.09, blue: 0.31, alpha: 1.0)
        case .dwp:
            return UIColor(red: 0.53, green: 0.17, blue: 0.24, alpha: 1.0)
        case .hmpo:
            return UIColor(red: 0.29, green: 0.13, blue: 0.55, alpha: 1.0)
        case .pilotDepartment:
            return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }

    var iconLetter: String {
        switch self {
        case .dvla: return "DVLA"
        case .hmrc: return "HMRC"
        case .govuk: return "GOV"
        case .dwp: return "DWP"
        case .hmpo: return "HMPO"
        case .pilotDepartment: return "PILOT"
        }
    }
}

// MARK: - Actions & Status

enum ActionStatus: String {
    case actionRequired = "Action required"
    case paymentPending = "Payment pending"
    case paid = "Paid"
    case complete = "Complete"

    var iconName: String {
        switch self {
        case .actionRequired:
            return "exclamationmark.circle.fill"
        case .paymentPending:
            return "clock.fill"
        case .paid, .complete:
            return "checkmark.circle.fill"
        }
    }

    var color: UIColor {
        switch self {
        case .actionRequired:
            return UIColor(red: 0.85, green: 0.47, blue: 0.0, alpha: 1.0)
        case .paymentPending:
            return UIColor(red: 0.0, green: 0.45, blue: 0.74, alpha: 1.0)
        case .paid, .complete:
            return UIColor(red: 0.0, green: 0.54, blue: 0.27, alpha: 1.0)
        }
    }
}

enum MessageAction {
    case applyInApp(title: String, destination: MessageDestination)
    case openURL(title: String, url: URL)
    case payment(title: String, amount: Int, reference: String)
}

enum MessageDestination: String {
    case dvlaRenewLicence
    case dvlaVehicleTax
}

// MARK: - Message

struct MailboxMessage: Identifiable, Decodable {
    let messageId: String
    let mailboxId: String
    let receivedAt: String
    let subject: String
    let senderDept: String
    let body: String?
    var readAt: String?

    var id: String { messageId }

    var sender: MessageSender? {
        MessageSender(rawValue: senderDept)
    }

    var senderDisplayName: String {
        sender?.displayName ?? senderDept
    }

    var senderColor: UIColor {
        sender?.iconColor ?? UIColor.systemGray
    }

    var senderLetter: String {
        sender?.iconLetter ?? String(senderDept.prefix(1)).uppercased()
    }

    var isUnopened: Bool { readAt == nil }

    var receivedDate: Date? {
        Self.isoFormatter.date(from: receivedAt)
            ?? Self.isoFractionalFormatter.date(from: receivedAt)
    }

    // MARK: - Body parsing (strips embedded actions)

    var displayBody: String {
        parsedContent.body
    }

    var parsedActions: [MessageAction] {
        parsedContent.actions
    }

    var parsedStatus: ActionStatus? {
        parsedContent.status
    }

    private var parsedContent: ParsedMessageContent {
        MessageBodyParser.parse(body)
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    private static let isoFractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

struct MailboxMessagesResponse: Decodable {
    let messages: [MailboxMessage]
    let nextToken: String?
}

// MARK: - Body Parser

struct ParsedMessageContent {
    let body: String
    let actions: [MessageAction]
    let status: ActionStatus?
}

enum MessageBodyParser {
    private static let marker = "<!-- ACTIONS:"

    static func parse(_ rawBody: String?) -> ParsedMessageContent {
        guard let rawBody, !rawBody.isEmpty else {
            return ParsedMessageContent(body: "", actions: [], status: nil)
        }

        guard let markerRange = rawBody.range(of: marker) else {
            return ParsedMessageContent(body: rawBody, actions: [], status: nil)
        }

        let displayBody = String(rawBody[..<markerRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let jsonStart = markerRange.upperBound
        guard let endRange = rawBody.range(of: "-->", range: jsonStart..<rawBody.endIndex) else {
            return ParsedMessageContent(body: displayBody, actions: [], status: nil)
        }

        let jsonString = String(rawBody[jsonStart..<endRange.lowerBound])
            .trimmingCharacters(in: .whitespaces)

        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return ParsedMessageContent(body: displayBody, actions: [], status: nil)
        }

        let status: ActionStatus?
        if let statusString = json["status"] as? String {
            status = ActionStatus(rawValue: statusString)
        } else {
            status = nil
        }

        var actions: [MessageAction] = []
        if let actionArray = json["actions"] as? [[String: Any]] {
            for actionDict in actionArray {
                if let action = parseAction(actionDict) {
                    actions.append(action)
                }
            }
        }

        return ParsedMessageContent(body: displayBody, actions: actions, status: status)
    }

    private static func parseAction(_ dict: [String: Any]) -> MessageAction? {
        guard let type = dict["type"] as? String,
              let title = dict["title"] as? String else {
            return nil
        }

        switch type {
        case "payment":
            guard let amount = dict["amount"] as? Int,
                  let reference = dict["reference"] as? String else {
                return nil
            }
            return .payment(title: title, amount: amount, reference: reference)
        case "openURL":
            guard let urlString = dict["url"] as? String,
                  let url = URL(string: urlString) else {
                return nil
            }
            return .openURL(title: title, url: url)
        case "applyInApp":
            guard let destinationString = dict["destination"] as? String,
                  let destination = MessageDestination(rawValue: destinationString) else {
                return nil
            }
            return .applyInApp(title: title, destination: destination)
        default:
            return nil
        }
    }
}
