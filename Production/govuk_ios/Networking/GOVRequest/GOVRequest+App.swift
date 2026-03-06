import Foundation
import GovKit

extension GOVRequest {
    static var config: GOVRequest {
        GOVRequest(
            urlPath: "/config/appinfo/ios",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            signingKey: Constants.SigningKey.govUK,
            requiresAuthentication: false
        )
    }
}
