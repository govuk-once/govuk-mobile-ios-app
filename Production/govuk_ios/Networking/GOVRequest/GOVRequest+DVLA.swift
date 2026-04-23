import Foundation
import GovKit

extension GOVRequest {
    private static let dvlaPath = "/app/dvla/v1"
    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var drivingLicence: GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/driving-licence",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static var driverSummary: GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/driver-summary",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true)
    }
}
