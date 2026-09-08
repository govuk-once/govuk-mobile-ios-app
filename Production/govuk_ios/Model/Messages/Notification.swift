import Foundation

struct Notification: Identifiable,
                     Codable,
                     Equatable {
    let id: String
    let title: String
    let body: String
    let date: Date
    let status: String
    let messageTitle: String?
    let messageBody: String?
    let metadata: Metadata

    var isUnread: Bool {
        status != "READ"
    }

    var senderName: String {
        metadata.sender.displayName
    }

    enum CodingKeys: String, CodingKey {
        case id = "NotificationID"
        case title = "NotificationTitle"
        case body = "NotificationBody"
        case date = "DispatchedDateTime"
        case status = "Status"
        case messageTitle = "MessageTitle"
        case messageBody = "MessageBody"
        case metadata = "Metadata"
    }
}

extension Notification {
    struct Metadata: Codable,
                     Equatable {
        let sender: Sender

        enum CodingKeys: String, CodingKey {
            case sender = "Sender"
        }
    }
}

extension Notification.Metadata {
    struct Sender: Codable,
                   Equatable {
        let displayName: String
        enum CodingKeys: String,
                         CodingKey {
            case displayName = "DisplayName"
        }
    }
}
