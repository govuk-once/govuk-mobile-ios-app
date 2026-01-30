import Foundation
import GovKit

extension GOVRequest {
    static func getUserState(accessToken: String?) -> GOVRequest {
        let accessToken = accessToken ?? ""
        return GOVRequest(
            urlPath: "/1.0/app/user",
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: ["Authorization": "Bearer \(accessToken)"]
        )
    }
}
