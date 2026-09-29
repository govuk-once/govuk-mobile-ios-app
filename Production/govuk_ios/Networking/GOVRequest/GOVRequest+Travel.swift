import Foundation
import GovKit

extension GOVRequest {
    private static let groupsPath = "/app/groups/v1/groups"
    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    static var travelGroups: GOVRequest {
        GOVRequest(
            urlPath: groupsPath,
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static var countriesList: GOVRequest {
        GOVRequest(
            urlPath: "/app/travel/v1/countries",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func subscribeToGroups(subscriptionsBody: [SubscriptionRequest]) -> GOVRequest {
        return GOVRequest(
            urlPath: groupsPath,
            method: .post,
            body: subscriptionsBody,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }
}
