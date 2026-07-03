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
            requiresAuthentication: true
        )
    }

    static var customerSummary: GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/customer-summary",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func vehicle(registration: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/vehicle-enquiry/\(registration)",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static var createShareCode: GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/share-code",
            method: .post,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static var listShareCodes: GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/share-codes",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func cancelShareCode(id: String) -> GOVRequest {
        GOVRequest(
            urlPath: "\(dvlaPath)/share-code/\(id)/cancel",
            method: .post,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }
}
