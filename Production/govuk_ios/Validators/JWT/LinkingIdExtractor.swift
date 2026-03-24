import Foundation
import JWTKit

protocol LinkingIdExtractor {
    func extract(jwt: String) async throws -> LinkingIdPayload
}

struct JWTLinkingIdExtractor: LinkingIdExtractor {
    let signers = JWTKeyCollection()

    func extract(jwt: String) async throws -> LinkingIdPayload {
        return try await signers.unverified(jwt)
    }
}
