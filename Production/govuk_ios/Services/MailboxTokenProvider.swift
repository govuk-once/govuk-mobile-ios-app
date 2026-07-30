import Foundation

class MailboxTokenProvider: TokenProviding {
    private let tokenAPIClient: APIServiceClientInterface
    private let authSystemSub: String
    private var cachedToken: String?

    init(tokenAPIClient: APIServiceClientInterface,
         authSystemSub: String = "ios-demo-citizen") {
        self.tokenAPIClient = tokenAPIClient
        self.authSystemSub = authSystemSub
    }

    var accessToken: String? { cachedToken }

    func tokenRefreshRequest() async -> TokenRefreshResult {
        await withCheckedContinuation { continuation in
            let request = GOVRequest.mailboxToken(authSystemSub: authSystemSub)
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
                        continuation.resume(returning: .failure(.genericError))
                    }
                case .failure:
                    continuation.resume(returning: .failure(.genericError))
                }
            }
        }
    }

    func fetchInitialToken() async -> Bool {
        let result = await tokenRefreshRequest()
        switch result {
        case .success: return true
        case .failure: return false
        }
    }
}

private struct MailboxTokenResponse: Decodable {
    let token: String
}
