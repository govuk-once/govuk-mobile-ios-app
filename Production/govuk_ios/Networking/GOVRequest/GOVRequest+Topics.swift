import Foundation
import GovKit

extension GOVRequest {
    static var topics: GOVRequest {
        GOVRequest(
            urlPath: "/static/topics/list",
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            signingKey: Constants.SigningKey.govUK,
            requiresAuthentication: false
        )
    }

    static func topic(ref: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/static/topics/" + ref,
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            signingKey: Constants.SigningKey.govUK,
            requiresAuthentication: false
        )
    }
}
