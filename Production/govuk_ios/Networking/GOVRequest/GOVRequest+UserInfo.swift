import Foundation
import GovKit

extension GOVRequest {
    static func getUserInfo(accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(
            urlPath: "/post-login",
            method: .post,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: ["Authorization": "Bearer \(accessToken)"]
        )
    }
}
