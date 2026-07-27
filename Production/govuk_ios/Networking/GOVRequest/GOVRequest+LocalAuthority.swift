import Foundation
import GovKit

extension GOVRequest {
    static func localAuthority(postcode: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/api/local-authority",
            method: .get,
            body: nil,
            queryParameters: ["postcode": postcode],
            additionalHeaders: nil,
            requiresAuthentication: false
        )
    }
    static func localAuthoritySlug(slug: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/api/local-authority/\(slug)",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: false
        )
    }
}
