import Foundation
import GovKit

struct Answer: Codable {
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case message
        case sources
        case status
        case feedback
    }

    let createdAt: String?
    let id: String?
    let message: String?
    let sources: [Source]?
    let status: String?
    let feedback: AnswerFeedback?

    var answerAvailable: Bool {
        id != nil
    }

    var isTechnicalError: Bool {
        status?.hasPrefix("error_") == true
    }
}

struct Source: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case url
    }

    let title: String
    let url: String
    var urlWithFallback: URL {
        URL(string: url) ?? Constants.API.govukBaseUrl
    }
}
