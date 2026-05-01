import Foundation
import JWTKit

protocol JWTExtractorInterface {
    func extract<T: JWTPayload>(jwt: String, as type: T.Type) async throws -> T
}

struct JWTExtractor: JWTExtractorInterface {
    let signers = JWTKeyCollection()

    func extract<T: JWTPayload>(jwt: String, as type: T.Type) async throws -> T {
        return try await signers.unverified(jwt, as: T.self)
    }
}
