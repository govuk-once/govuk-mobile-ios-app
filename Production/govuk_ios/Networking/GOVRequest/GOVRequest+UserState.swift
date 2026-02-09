import Foundation
import GovKit

extension GOVRequest {
    private static let userPath = "/app/v1/user"

    static func getUserState(accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(
            urlPath: userPath,
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: ["Authorization": "Bearer \(accessToken)"]
        )
    }

    static func setNotificationsConsent(accepted: Bool,
                                        accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(urlPath: userPath,
                          method: .patch,
                          bodyParameters: ["notificationsConsented": accepted],
                          queryParameters: nil,
                          additionalHeaders: ["Content-Type": "application/json",
                                              "Authorization": "Bearer \(accessToken)"]
        )
    }

    static func setAnalyticsConsent(accepted: Bool,
                                    accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(urlPath: userPath,
                          method: .patch,
                          bodyParameters: ["analyticsConsented": accepted],
                          queryParameters: nil,
                          additionalHeaders: ["Content-Type": "application/json",
                                              "Authorization": "Bearer \(accessToken)"]
        )
    }
}
