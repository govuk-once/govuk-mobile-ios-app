import Foundation

class MailboxTokenProvider: TokenProviding {
    private let tokenAPIClient: APIServiceClientInterface
    private let authService: AuthenticationServiceInterface
    private var cachedToken: String?

    init(tokenAPIClient: APIServiceClientInterface,
         authService: AuthenticationServiceInterface) {
        self.tokenAPIClient = tokenAPIClient
        self.authService = authService
    }

    var accessToken: String? { cachedToken }

    func tokenRefreshRequest() async -> TokenRefreshResult {
        let sub = await authService.userSub ?? "ios-demo-citizen"
        print("[Mailbox] tokenRefreshRequest using sub: \(sub)")
        return await withCheckedContinuation { continuation in
            let request = GOVRequest.mailboxToken(authSystemSub: sub)
            tokenAPIClient.send(request: request) { [weak self] result in
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(
                            MailboxTokenResponse.self,
                            from: data
                        )
                        self?.cachedToken = response.token
                        continuation.resume(returning: .success(
                            TokenRefreshResponse(
                                accessToken: response.token,
                                idToken: nil
                            )
                        ))
                    } catch {
                        print("[Mailbox] Token issuer decode error. Raw: \(String(data: data, encoding: .utf8) ?? "nil")")
                        continuation.resume(returning: .failure(.genericError))
                    }
                case .failure(let error):
                    print("[Mailbox] Token issuer network error: \(error)")
                    continuation.resume(returning: .failure(.genericError))
                }
            }
        }
    }

    func fetchInitialToken() async -> Bool {
        let result = await tokenRefreshRequest()
        switch result {
        case .success:
            print("[Mailbox] Initial token fetch succeeded")
            return true
        case .failure:
            print("[Mailbox] Initial token fetch FAILED")
            return false
        }
    }
}

private struct MailboxTokenResponse: Decodable {
    let token: String
}
