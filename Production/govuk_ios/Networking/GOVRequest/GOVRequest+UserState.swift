import Foundation
import GovKit

extension GOVRequest {
    private static let userPath = "/app/v1/user"

    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var userState: GOVRequest {
        GOVRequest(
            urlPath: userPath,
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: true
        )
    }

    static func setNotificationsConsent(consentStatus: ConsentStatus) -> GOVRequest {
        let body = NotificationsPreferenceUpdate(
            preferences: UserPreferences(
                notifications: ConsentPreference(
                    consentStatus: consentStatus
                )
            )
        )
        return GOVRequest(
            urlPath: userPath,
            method: .patch,
            body: body,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }
}

struct NotificationsPreferenceUpdate: Codable {
    let preferences: UserPreferences
}
