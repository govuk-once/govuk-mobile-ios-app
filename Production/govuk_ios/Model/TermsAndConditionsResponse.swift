import Foundation

struct TermsAndConditionsResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case publicUpdatedAt = "public_updated_at"
    }

    var publicUpdatedAt: Date
}
