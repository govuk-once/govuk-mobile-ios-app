import Foundation
import XCTest
import SwiftUI

@testable import govuk_ios

final class ChatViewControllerSnapshotTests: SnapshotTestCase {
    func test_loadInNavigationController_newChat_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: newChatView,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_newChat_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: newChatView,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: view(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: view(),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_noSources_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: view(includeSources: false),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_noSources_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: view(includeSources: false),
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_generatingAnswer_light_rendersCorrectly() {
        let mockChatService = MockChatService()
        let conversationId = "conversationId"
        mockChatService._stubbedConversationId = conversationId
        // An authenticationError will prevent the history from loading on
        // view appearance
        mockChatService._stubbedQuestionResult = .failure(.authenticationError)

        let viewModel = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        viewModel.askQuestion()
        // With no history loading to create cellModels, modify the array
        // directly
        let loadingModel = ChatCellViewModel.loadingQuestion
        loadingModel.isVisible = true
        let gettingAnswerModel = ChatCellViewModel.gettingAnswer
        gettingAnswerModel.isVisible = true
        viewModel.cellModels = [loadingModel, gettingAnswerModel]

        let view = ChatView(viewModel: viewModel)
            .environment(\.isTesting, true)

        VerifySnapshotInNavigationController(
            view: view,
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_generatingAnswer_dark_rendersCorrectly() {
        let mockChatService = MockChatService()
        let conversationId = "conversationId"
        mockChatService._stubbedConversationId = conversationId
        mockChatService._stubbedQuestionResult = .failure(.authenticationError)

        let viewModel = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        viewModel.askQuestion()

        let loadingModel = ChatCellViewModel.loadingQuestion
        loadingModel.isVisible = true
        let gettingAnswerModel = ChatCellViewModel.gettingAnswer
        gettingAnswerModel.isVisible = true
        viewModel.cellModels = [loadingModel, gettingAnswerModel]

        let view = ChatView(viewModel: viewModel)
            .environment(\.isTesting, true)

        VerifySnapshotInNavigationController(
            view: view,
            mode: .dark,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_markdown_light_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: markdownView(),
            mode: .light,
            navBarHidden: true
        )
    }

    func test_loadInNavigationController_markdown_dark_rendersCorrectly() {
        VerifySnapshotInNavigationController(
            view: markdownView(),
            mode: .dark,
            navBarHidden: true
        )
    }

    private func view(includeSources: Bool = true) -> some View {
        let mockChatService = MockChatService()
        let conversationId = "conversationId"
        let createdAt = "\(Date())"
        let sources: [Source] = [
            .init(
                title: "source 1",
                url: "http://www.source1.com"
            ),
            .init(
                title: "source 2",
                url: "http://www.source2.com"
            )
        ]

        let answer = Answer(
            createdAt: createdAt,
            id: "12345",
            message: "This is the answer",
            sources: includeSources ? sources : nil
        )

        let answeredQuestion = AnsweredQuestion(
            answer: answer,
            conversationId: conversationId,
            createdAt: createdAt,
            id: "1",
            message: "This is the question"
        )

        let pendingQuestion = PendingQuestion(
            answerUrl: "https://www.example.com",
            conversationId: conversationId,
            createdAt: createdAt,
            id: "78910",
            message: "This is the pending question"
        )
        let pendingAnswer = Answer(
            createdAt: createdAt,
            id: "12346",
            message: "This is the pending answer",
            sources: includeSources ? sources : nil
        )

        let history = History(
            pendingQuestion: pendingQuestion,
            answeredQuestions: [answeredQuestion],
            createdAt: createdAt,
            id: "4456"
        )

        mockChatService._stubbedConversationId = conversationId
        mockChatService._stubbedHistoryResult = .success(history)
        mockChatService._stubbedQuestionResult = .success(pendingQuestion)
        mockChatService._stubbedAnswerResults = [.success(pendingAnswer)]

        let viewModel = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        viewModel.loadHistory()

        if includeSources {
            viewModel.cellModels.forEach { model in
                model.isSourceListExpanded = true
            }
        }

        let view = ChatView(viewModel: viewModel)
            .environment(\.isTesting, true)
        return view
    }

    private func markdownView() -> some View {
        let mockChatService = MockChatService()
        let conversationId = "conversationId"
        let createdAt = "\(Date())"
        mockChatService._stubbedConversationId = conversationId
        // An authenticationError will prevent the history from loading on
        // view appearance
        mockChatService._stubbedQuestionResult = .failure(.authenticationError)

        let viewModel = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        viewModel.askQuestion()
        // With no history loading to create cellModels, modify the array
        // directly

        let answer = Answer(
            createdAt: createdAt,
            id: "12345",
            message: """
                # Heading 1
                ## Heading 2
                ### Heading 3
                #### Heading 4
                ##### Heading 5
                ###### Heading 6
                * Bullet 1
                * Bullet 2
                1. Number 1
                2. Number 2
                """,
            sources: nil
        )

        let cellModel = ChatCellViewModel(answer: answer,
                                          openURLAction: { _ in },
                                          analyticsService: MockAnalyticsService())
        cellModel.isVisible = true
        viewModel.cellModels = [cellModel]

        return ChatView(viewModel: viewModel)
            .environment(\.isTesting, true)
    }

    private var newChatView: some View {
        let mockConfigService = MockAppConfigService()
        mockConfigService._stubbedChatExampleQuestions = [
            "First question",
            "Second question that is quite long and has a lot of text saying not a lot",
            "Third question"
        ]
        let viewModel = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: MockAnalyticsService(),
            configService: mockConfigService,
            openURLAction: { _ in },
            handleError: { _ in }
        )

        viewModel.loadHistory()
        // isVisible is set on main DispatchQueue and not executed before
        // snapshot is taken so setting manually
        viewModel.cellModels.first?.isVisible = true

        let view = ChatView(viewModel: viewModel)
            .environment(\.isTesting, true)
        return view
    }
}
