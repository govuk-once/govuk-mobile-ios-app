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
        #expect(sut.exampleQuestions.first?.accessibilityLabel == "Try asking: First question")
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

    @Test
    func trackEcommerce_tracks_viewItemList() {
        let mockConfigService = MockAppConfigService()
        let analyticsService = MockAnalyticsService()
        mockConfigService._stubbedChatExampleQuestions = [
            "First question",
            "Second question",
            "Third question"
        ]
        let sut = ChatExampleQuestionsViewModel(
            analyticsService: analyticsService,
            configService: mockConfigService
        )
        sut.trackEcommerce()

        #expect(analyticsService._trackedEvents.count == 1)
        #expect(analyticsService._trackedEvents.first?.name == "view_item_list")
        let params = analyticsService._trackedEvents.first!.params!
        #expect(params["item_list_name"] as? String == "chat suggestions")
        #expect(params["item_list_id"] as? String == "chat suggestions")
        #expect(params["results"] as? Int == 3)
        #expect((params["items"] as? [[String: String]])?.count == 3)
        let lastParam = (params["items"] as? [[String: String]])?.last
        #expect(lastParam?["item_name"] == "Third question")
        #expect(lastParam?["index"] == "3")
        #expect(lastParam?["item_list_id"] == "chat_suggestion")
    }

    @Test
    func trackEcommerceItemSelected_tracks_item() {
        let mockConfigService = MockAppConfigService()
        let analyticsService = MockAnalyticsService()
        mockConfigService._stubbedChatExampleQuestions = [
            "First question",
            "Second question",
            "Third question"
        ]
        let sut = ChatExampleQuestionsViewModel(
            analyticsService: analyticsService,
            configService: mockConfigService
        )
        sut.trackEcommerceItemSelected(text: "Second question", index: 2)

        #expect(analyticsService._trackedEvents.count == 1)
        #expect(analyticsService._trackedEvents.first?.name == "select_item")
        let params = analyticsService._trackedEvents.first!.params!
        #expect(params["item_list_name"] as? String == "chat suggestions")
        #expect(params["item_list_id"] as? String == "chat suggestions")
        #expect(params["results"] as? Int == 3)
        #expect((params["items"] as? [[String: String]])?.count == 1)
        let param = (params["items"] as? [[String: String]])?.first
        #expect(param?["item_name"] == "Second question")
        #expect(param?["index"] == "2")
        #expect(param?["item_list_id"] == "chat_suggestion")
    }
}
