import Foundation
import GovKit

extension GOVRequest {
    private static let userPath = "/app/v1/user"
    private static let userPreferencesPath = "/app/v1/user/preferences"

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

    static func setNotificationsConsent(consentStatus: ConsentStatus) -> GOVRequest {
        GOVRequest(
            urlPath: userPreferencesPath,
            method: .patch,
            bodyParameters: [
                "notifications": consentStatus
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
