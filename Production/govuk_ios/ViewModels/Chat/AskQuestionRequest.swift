import Foundation

struct AskQuestionRequest {
    let question: String?
    let type: QuestionType

    enum QuestionType: String {
        case typed
        case suggestion
    }

    static func typed(question: String? = nil) -> Self {
        .init(question: question, type: .typed)
    }

    static func suggestion(question: String? = nil) -> Self {
        .init(question: question, type: .suggestion)
    }
}
