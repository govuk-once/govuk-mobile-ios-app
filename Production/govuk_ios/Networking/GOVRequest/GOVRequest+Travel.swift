import Foundation
import GovKit

extension GOVRequest {
    private static let notificationsPath = "/app/uns/v1/notifications"
    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var travelGroups: GOVRequest {
        GOVRequest(
            urlPath: notificationsPath,
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }
}
