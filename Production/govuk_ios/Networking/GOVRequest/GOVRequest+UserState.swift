import Foundation
import GovKit

extension GOVRequest {
    static var userState: GOVRequest {
        GOVRequest(
            urlPath: "/app/udp/v1/usersz",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: true
        )
    }

    static func setNotificationsConsent(consentStatus: ConsentStatus) -> GOVRequest {
        let body = ConsentPreference(consentStatus: consentStatus)
        return GOVRequest(
            urlPath: "/app/udp/v1/usersz/notifications",
            method: .patch,
            body: body,
            queryParameters: nil,
            additionalHeaders: [
                "Content-Type": "application/json"
            ],
            requiresAuthentication: true
        )
    }
}
