import Foundation
import GovKit

extension GOVRequest {
    static func linkAccount(linkId: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/app/v1/udp/identity/dvla/\(linkId)",
            method: .post,
            body: nil,
            queryParameters: nil,
            additionalHeaders: nil,
            requiresAuthentication: true
        )
    }
}
