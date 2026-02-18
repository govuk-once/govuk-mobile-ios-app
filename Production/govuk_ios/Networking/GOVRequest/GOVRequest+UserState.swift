import Foundation
import GovKit

extension GOVRequest {
    private static let userPath = "/app/v1/user"

    static var userState: GOVRequest {
        GOVRequest(
            urlPath: userPath,
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: true
        )
    }

    static func setNotificationsConsent(accepted: Bool) -> GOVRequest {
        GOVRequest(
            urlPath: userPath,
            method: .patch,
            bodyParameters: [
                "notificationsConsented": accepted
            ],
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
}
