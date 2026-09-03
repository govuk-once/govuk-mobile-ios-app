import Foundation
import XCTest
import SwiftUI

@testable import govuk_ios

final class ChatExampleQuestionsViewSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_exampleQuestions_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: exampleQuestionsView,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_exampleQuestions_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: exampleQuestionsView,
            mode: .dark,
            navBarHidden: true
        )
    }

    private var exampleQuestionsView: some View {
        let mockConfigService = MockAppConfigService()
        mockConfigService._stubbedChatExampleQuestions = [
            "First question",
            "Second question that is quite long and has a lot of text saying not a lot",
            "Third question"
        ]
        let viewModel = ChatExampleQuestionsViewModel(
            analyticsService: MockAnalyticsService(),
            configService: mockConfigService
        )

        return ChatExampleQuestionsView(
            viewModel: viewModel,
            askQuestion: { _ in }
        )
    }
}

