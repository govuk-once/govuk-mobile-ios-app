import Foundation
import UIKit
import GovKit
import AuthenticationServices

protocol DVLAAuthSessionInterface {
    init(window: UIWindow, sessionType: ASWebAuthenticationSessionInterface.Type)
    func start(config: DVLAAuthSessionConfig) async throws -> URL
}

struct DVLAAuthSessionConfig {
    let authenticationUrl: URL
    let callbackUrlScheme: String
}

final class DVLAAuthSession: NSObject, DVLAAuthSessionInterface {
    private let sessionType: ASWebAuthenticationSessionInterface.Type
    private let window: UIWindow

    init(window: UIWindow,
         sessionType: ASWebAuthenticationSessionInterface.Type
    ) {
        self.window = window
        self.sessionType = sessionType
    }

    func start(config: DVLAAuthSessionConfig) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = sessionType.init(
                url: config.authenticationUrl,
                callbackURLScheme: config.callbackUrlScheme,
                completionHandler: { [weak self] url, error in
                    self?.handleContinuation(
                        continuation,
                        callbackUrl: url,
                        error: error
                    )
                }
            )
            session.prefersEphemeralWebBrowserSession = true
            session.presentationContextProvider = self
            session.start()
        }
    }

    private func handleContinuation(
        _ continuation: CheckedContinuation<URL, Error>,
        callbackUrl: URL?,
        error: Error?
    ) {
        do {
            let url = try handleAuthResult(callbackUrl: callbackUrl, error: error)
            continuation.resume(returning: url)
        } catch {
            continuation.resume(throwing: error)
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
            throw DVLAAuthError.invalidCallbackUrl
        }
    }
}

extension DVLAAuthSession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        window
    }
}
