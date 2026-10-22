import Foundation

@testable import govuk_ios

extension AnswerFeedback {
    static var arrange: AnswerFeedback {
        arrange()
    }

    static func arrange(reaction: String = "positive",
                        createdAt: String = "2025-06-06T10:30:00+01:00") -> AnswerFeedback {
        .init(reaction: reaction,
              createdAt: createdAt)
    }
}
