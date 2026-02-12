import Foundation
import GovKit

extension GOVRequest {
    static func localAuthority(postcode: String) -> GOVRequest {
        GOVRequest(
            urlPath: Constants.API.localAuthorityPath,
            method: .get,
            bodyParameters: nil,
            queryParameters: ["postcode": postcode],
            additionalHeaders: nil,
            requiresAuthentication: false
        )
    }
    static func localAuthoritySlug(slug: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(Constants.API.localAuthorityPath)/\(slug)",
            method: .get,
            bodyParameters: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: false
        )
    }
}
