//


extension GOVRequest {
    private static let notificationsPath = "/app/uns/v1/notifications"

    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var notifications: GOVRequest {
        GOVRequest(
            urlPath: notificationsPath,
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: true
        )
    }

    static func singleNotification(with id: String) -> GOVRequest {
        return GOVRequest(
            urlPath: "\(notificationsPath)/\(id)",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func deleteNotification(with id: String) -> GOVRequest {
        return GOVRequest(
            urlPath: "\(notificationsPath)/\(id)",
            method: .delete,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    // swiftlint:disable:next todo
    // TODO Put this status somewhere more sensible
    static func update(status: UpdateBody.Status, with id: String) -> GOVRequest {
        return GOVRequest(
            urlPath: "\(notificationsPath)/\(id)/status",
            method: .patch,
            body: UpdateBody(status: status),
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    struct UpdateBody: Codable {
        enum Status: String, Codable {
            case read
            case unread

            func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .read:
                    try container.encode("READ")
                case.unread:
                    try container.encode("MARKED_AS_UNREAD")
                }
            }
        }
        let status: Status
        enum CodingKeys: String, CodingKey {
            case status = "Status"
        }
    }
}
