import Foundation
import GovKit

extension GOVRequest {
    static func termsAndConditions(path: String) -> GOVRequest {
        GOVRequest(
            urlPath: path,
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: false
        )
    }

    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
}
