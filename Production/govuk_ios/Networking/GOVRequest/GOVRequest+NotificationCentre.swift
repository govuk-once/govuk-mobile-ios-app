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
            case read = "READ"
            case unread = "MARKED_AS_UNREAD"
        }
        let status: Status

        enum CodingKeys: String, CodingKey {
            case status = "Status"
        }
    }
}
