import Foundation

struct AnswerFeedback: Codable {
    enum CodingKeys: String, CodingKey {
        case reaction
        case createdAt = "created_at"
    }

    let reaction: String
    let createdAt: String
}
