import Foundation
import GovKit

extension GOVRequest {
    static func askQuestion(_ question: String,
                            conversationId: String? = nil) -> GOVRequest {
        var path = "/conversation"
        if let conversationId = conversationId {
            path += "/\(conversationId)"
        }
        return GOVRequest(
            urlPath: path,
            method: conversationId != nil ? .put : .post,
            body: Question(userQuestion: question),
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func getChatHistory(conversationId: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/conversation/\(conversationId)",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    static func getAnswer(conversationId: String,
                          questionId: String) -> GOVRequest {
        GOVRequest(
            urlPath: "/conversation/\(conversationId)/questions/\(questionId)/answer",
            method: .get,
            body: nil,
            queryParameters: nil,
            additionalHeaders: additionalHeaders,
            requiresAuthentication: true
        )
    }

    private static var additionalHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }
}

struct Question: Codable {
    let userQuestion: String

    enum CodingKeys: String, CodingKey {
        case userQuestion = "user_question"
    }
}
