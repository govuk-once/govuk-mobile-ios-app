import Foundation
import GovKit

extension GOVRequest {
    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var travelGroups: GOVRequest {
        GOVRequest(
            urlPath: "/app/uns/v1/notifications",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static var countriesList: GOVRequest {
        GOVRequest(
            urlPath: "/travel/v1/countries",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }
}
