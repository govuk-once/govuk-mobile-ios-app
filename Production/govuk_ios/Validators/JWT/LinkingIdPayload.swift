import Foundation
import JWTKit

struct LinkingIdPayload: JWTPayload {
    let exp: Double
    let linkingId: String
    func verify(using algorithm: some JWTAlgorithm) async throws { /* protocol conformance */ }

    enum CodingKeys: String, CodingKey {
        case exp
        case linkingId = "linking_id"
    }
}
