import Foundation
import GovKit

extension GOVRequest {
    static func askQuestion(_ question: String,
                            isSuggestedPrompt: Bool?,
                            conversationId: String? = nil) -> GOVRequest {
        var path = "/conversation"
        if let conversationId = conversationId {
            path += "/\(conversationId)"
        }
        return GOVRequest(
            urlPath: path,
            method: conversationId != nil ? .put : .post,
            body: Question(userQuestion: question,
                           isSuggestedPrompt: isSuggestedPrompt
                          ),
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

    static func sendChatFeedback(conversationId: String,
                                 answerId: String,
                                 isPositive: Bool) -> GOVRequest {
        GOVRequest(
            urlPath: "/conversation/\(conversationId)/answers/\(answerId)/feedback",
            method: .post,
            body: ChatFeedbackReaction(reaction: isPositive ? "positive" : "negative"),
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
    let isSuggestedPrompt: Bool?

    enum CodingKeys: String, CodingKey {
        case userQuestion = "user_question"
        case isSuggestedPrompt = "suggested_prompt"
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userQuestion, forKey: .userQuestion)
        if isSuggestedPrompt == true {
            try container.encode(true, forKey: .isSuggestedPrompt)
        }
    }
}
