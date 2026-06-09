import Foundation
import Authentication

extension TokenResponse {

    static var arrange: Authentication.TokenResponse {
        .arrange()
    }

    static func arrange (
        accessToken: String = "access_token_value",
        refreshToken: String? = "refresh_token_value",
        idToken: String? = "id_token",
        expiryDate: String = "2099-01-01T00:00:00Z"
    ) -> Authentication.TokenResponse {
        let jsonData = """
        {
            "accessToken": "\(accessToken)",
            "refreshToken": "\(refreshToken ?? "")",
            "idToken": "\(idToken ?? "")",
            "tokenType": "id_token",
            "expiryDate": "\(expiryDate)"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(TokenResponse.self, from: jsonData)
        } catch {
            fatalError("Failed to decode TokenResponse: \(error)")
        }
    }
}
