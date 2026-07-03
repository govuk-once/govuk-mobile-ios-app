import Foundation
import JWTKit

protocol JWTExtractorInterface {
    func extract<T: JWTPayload>(jwt: String) async throws -> T
}

struct JWTExtractor: JWTExtractorInterface {
    let signers = JWTKeyCollection()

    func extract<T: JWTPayload>(jwt: String) async throws -> T {
        try await signers.unverified(jwt, as: T.self)
    }
}
