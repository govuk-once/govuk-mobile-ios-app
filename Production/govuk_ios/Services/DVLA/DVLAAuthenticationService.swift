import Foundation
import AuthenticationServices
import GovKit

typealias DVLAAuthResult = Result<String, DVLAAuthError>

protocol DVLAAuthenticationServiceInterface {
    func authenticate(window: UIWindow) async -> DVLAAuthResult
}

class DVLAAuthenticationService: DVLAAuthenticationServiceInterface {
    private let authenticationUrl = {
        URL(string: "https://architecture-link-account-service-ui-ext.dvla.gov.uk/")!
    }()
    private let sessionBuilder: DVLAAuthSessionBuilderInterface

    init(sessionBuilder: DVLAAuthSessionBuilderInterface) {
        self.sessionBuilder = sessionBuilder
    }

    func authenticate(window: UIWindow) async -> DVLAAuthResult {
        do {
            let session = sessionBuilder.session(window: window)
            let config = DVLAAuthSessionConfig(
                authenticationUrl: authenticationUrl,
                callbackUrlScheme: "govuk"
            )
            let callbackUrl = try await session.start(config: config)
            let token = try extractToken(from: callbackUrl)
            let linkId = try await extractLinkId(from: token)
            return .success(linkId)
        } catch let error as DVLAAuthError {
            return .failure(error)
        } catch {
            return .failure(DVLAAuthError.unknown)
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
