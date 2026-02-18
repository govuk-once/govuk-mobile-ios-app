import Foundation

@testable import govuk_ios

extension TokenRefreshResponse {
    static var arrange: TokenRefreshResponse {
        arrange()
    }

    static func arrange(accessToken: String = "accessToken") -> TokenRefreshResponse{
        .init(accessToken: accessToken,
              idToken: nil)
    }
}
