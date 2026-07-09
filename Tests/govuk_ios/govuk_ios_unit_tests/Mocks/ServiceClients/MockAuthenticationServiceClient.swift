import Foundation
import UIKit
import Authentication

@testable import govuk_ios

class MockAuthenticationServiceClient: AuthenticationServiceClientInterface {
    var _stubbedTokenRefreshResult: TokenRefreshResult = .failure(.tokenResponseError)
    func performTokenRefresh(refreshToken: String) async -> TokenRefreshResult {
        _stubbedTokenRefreshResult
    }

    var _stubbedAuthenticationResult: AuthenticationResult = .failure(.loginFlow(.init(reason: .authorizationAccessDenied)))
    func performAuthenticationFlow(window: UIWindow) async -> AuthenticationResult {
        _stubbedAuthenticationResult
    }

    func revokeToken(_ refreshToken: String?, completion: (() -> Void)?) {
        completion?()
    }

    var _stubbedFetchIdentityVerificationResult: IdentityVerificationResult = .failure(.apiUnavailable)
    func fetchIdentityVerification(accesstoken: String) async -> IdentityVerificationResult {
        _stubbedFetchIdentityVerificationResult
    }
}
