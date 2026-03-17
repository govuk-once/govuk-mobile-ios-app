import Foundation
import GovKit

extension GOVRequest {
    private static let userPath = "/app/v1/users"
    private static let userNotificationsPath = "/app/v1/users/notifications"

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
        let body = ConsentPreference(consentStatus: consentStatus)
        return GOVRequest(
            urlPath: userNotificationsPath,
            method: .patch,
            body: body,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func linkAccount(serviceName: String, linkId: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/app/v1/identity/\(serviceName)/\(linkId)",
            method: .post,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: true
        )
    }

    static func unlinkAccount(serviceName: String) -> GOVRequest {
        GOVRequest(urlPath: "app/v1/identity/\(serviceName)",
                   method: .delete,
                   body: nil,
                   queryParameters: nil,
                   additionalHeaders: nil,
                   requiresAuthentication: true
        )
    }
}
