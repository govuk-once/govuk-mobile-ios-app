import Foundation
import Testing
import GovKit

@testable import govuk_ios

struct ChatExampleQuestionsViewModelTests {
    @Test
    func exampleQuestions_present_createsQuestionsArray() {
        let mockConfigService = MockAppConfigService()
        mockConfigService._stubbedChatExampleQuestions = [
            "First question",
            "Second question",
            "Third question"
        ]
        let sut = ChatExampleQuestionsViewModel(
            analyticsService: MockAnalyticsService(),
            configService: mockConfigService
        )

        #expect(sut.exampleQuestions.count == 3)
        #expect(sut.exampleQuestions.first?.body == "First question")
    }

    @Test
    func exampleQuestions_absent_returnsEmptyArray() {
        let mockConfigService = MockAppConfigService()
        mockConfigService._stubbedChatExampleQuestions = nil
        let sut = ChatExampleQuestionsViewModel(
            analyticsService: MockAnalyticsService(),
            configService: mockConfigService
        )

        #expect(sut.exampleQuestions.isEmpty == true)
    }
}
