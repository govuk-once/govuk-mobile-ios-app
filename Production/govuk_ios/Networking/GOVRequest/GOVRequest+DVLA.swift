import Foundation
import GovKit

extension GOVRequest {
    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var drivingLicence: GOVRequest {
        GOVRequest(
            urlPath: "/app/dvla/v1/driving-licence",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }
}
