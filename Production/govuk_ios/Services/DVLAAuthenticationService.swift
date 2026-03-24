import Foundation
import AuthenticationServices
import GovKit

typealias DVLAAuthResult = Result<String, DVLAAuthError>

protocol DVLAAuthenticationServiceInterface {
    func authenticate(window: UIWindow) async -> DVLAAuthResult
}

class DVLAAuthenticationService: NSObject, DVLAAuthenticationServiceInterface {
    private let authenticationUrl = {
        URL(string: "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")!
    }()

    private var window: UIWindow?

    func authenticate(window: UIWindow) async -> DVLAAuthResult {
        self.window = window
        do {
            let callbackUrl = try await startAuthenticationSession()
            let token = try extractToken(from: callbackUrl)
            let linkId = try await extractLinkId(from: token)
            return .success(linkId)
        } catch let error as DVLAAuthError {
            return .failure(error)
        } catch {
            return .failure(DVLAAuthError.unknown)
        }
    }

    private func startAuthenticationSession() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authenticationUrl,
                callbackURLScheme: "govuk"
            ) { [weak self] callbackUrl, error in
                do {
                    guard let self = self else {
                        continuation.resume(throwing: DVLAAuthError.unknown)
                        return
                    }
                    let callbackUrl = try self.handleAuthResult(
                        callbackUrl: callbackUrl,
                        error: error
                    )
                    continuation.resume(returning: callbackUrl)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            session.prefersEphemeralWebBrowserSession = true
            session.presentationContextProvider = self
            session.start()
        }
    }


    private func handleAuthResult(callbackUrl: URL?, error: Error?) throws -> URL {
        if let error = error {
            if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin {
                throw DVLAAuthError.userCancelled
            } else {
                throw DVLAAuthError.unknown
            }
        } else if let callbackUrl = callbackUrl {
            return callbackUrl
        } else {
            throw DVLAAuthError.unknown
        }
    }

    private func extractToken(from url: URL) throws -> String {
        guard let urlComponents = URLComponents(string: url.absoluteString) else {
            throw DVLAAuthError.tokenNotFound
        }
        guard let token = urlComponents.queryItems?.first(where: {
            $0.name == "token"
        })?.value else {
            throw DVLAAuthError.tokenNotFound
        }
        return token
    }

    private func extractLinkId(from token: String) async throws -> String {
        do {
            let linkIdPayload = try await JWTLinkingIdExtractor().extract(jwt: token)
            return linkIdPayload.linkingId
        } catch {
            throw DVLAAuthError.linkIdNotFound
        }
    }
}

extension DVLAAuthenticationService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        window ?? UIWindow()
    }
}
