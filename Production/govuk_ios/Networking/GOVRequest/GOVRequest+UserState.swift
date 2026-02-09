import Foundation
import GovKit

extension GOVRequest {
    static func getUserState(accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(
            urlPath: "/app/v1/user",
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: ["Authorization": "Bearer \(accessToken)"]
        )
    }

    static func setNotificationsConsent(accepted: Bool,
                                        accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(urlPath: "/app/v1/user",
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
        return GOVRequest(urlPath: "/app/v1/user",
                          method: .patch,
                          bodyParameters: ["analyticsConsented": accepted],
                          queryParameters: nil,
                          additionalHeaders: ["Content-Type": "application/json",
                                              "Authorization": "Bearer \(accessToken)"]
        )
    }
}
