import Foundation
import GovKit

extension GOVRequest {
    static func revoke(token: String,
                       clientId: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/oauth2/revoke",
            method: .post,
            body: RevokeToken(
                token: token,
                clientId: clientId
            ),
            queryParameters: nil,
            additionalHeaders: ["Content-Type": "application/x-www-form-urlencoded"],
            requiresAuthentication: false
        )
    }

    static func identityVerification(token: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/linking/verification",
            method: .post,
            body: [
                "token": token
            ],
            queryParameters: nil,
            additionalHeaders: ["Content-Type": "application/json"],
            requiresAuthentication: false
        )
    }
}

struct RevokeToken: Codable {
    let token: String
    let clientId: String

    enum CodingKeys: String, CodingKey {
        case token = "token"
        case clientId = "client_id"
    }
}
