import Foundation
import UIKit

enum MessageStatus {
    case unopened
    case opened
}

enum MessageSender: String, CaseIterable {
    case dvla = "DVLA"
    case hmrc = "HMRC"
    case govuk = "GOV.UK"
    case manchesterCouncil = "Manchester City Council"
    case dwp = "DWP"

    var iconColor: UIColor {
        switch self {
        case .dvla:
            return UIColor(red: 0.0, green: 0.45, blue: 0.74, alpha: 1.0)
        case .hmrc:
            return UIColor(red: 0.0, green: 0.51, blue: 0.35, alpha: 1.0)
        case .govuk:
            return UIColor(red: 0.11, green: 0.09, blue: 0.31, alpha: 1.0)
        case .manchesterCouncil:
            return UIColor(red: 0.44, green: 0.16, blue: 0.56, alpha: 1.0)
        case .dwp:
            return UIColor(red: 0.53, green: 0.17, blue: 0.24, alpha: 1.0)
        }
    }

    var iconLetter: String {
        switch self {
        case .dvla: return "D"
        case .hmrc: return "H"
        case .govuk: return "G"
        case .manchesterCouncil: return "M"
        case .dwp: return "W"
        }
    }
}

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

enum MessageDestination {
    case dvlaRenewLicence
    case dvlaVehicleTax
}

struct MailboxMessage: Identifiable {
    let id: String
    let sender: MessageSender
    let subject: String
    let body: String
    let receivedDate: Date
    var status: MessageStatus
    let previewText: String
    let actions: [MessageAction]
    var actionStatus: ActionStatus?

    init(
        id: String,
        sender: MessageSender,
        subject: String,
        body: String,
        receivedDate: Date,
        status: MessageStatus,
        previewText: String,
        actions: [MessageAction] = [],
        actionStatus: ActionStatus? = nil
    ) {
        self.id = id
        self.sender = sender
        self.subject = subject
        self.body = body
        self.receivedDate = receivedDate
        self.status = status
        self.previewText = previewText
        self.actions = actions
        self.actionStatus = actionStatus
    }
}
