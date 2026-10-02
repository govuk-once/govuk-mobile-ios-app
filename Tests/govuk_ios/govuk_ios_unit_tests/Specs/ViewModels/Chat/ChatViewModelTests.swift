import Foundation
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct ChatViewModelTests {

    @Test
    func askQuestion_success_createsCorrectCellModels() async {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [.success(.answeredAnswer)]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = "This is the question"
        sut.askQuestion(.typed())

        #expect(sut.cellModels.count == 2)
        #expect(sut.cellModels.first?.type == .question)
        #expect(sut.cellModels.last?.type == .answer)
        #expect(sut.latestQuestion == "")
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func askQuestion_tracksAskAndResponseEvents() async {
        let mockChatService = MockChatService()
        let mockAnalyticsService = MockAnalyticsService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [.success(.answeredAnswer)]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = "This is the question"
        sut.askQuestion(.typed())

        #expect(mockAnalyticsService._trackedEvents.count == 2)
        let firstParams = mockAnalyticsService._trackedEvents.first?.params
        let lastParams = mockAnalyticsService._trackedEvents.last?.params
        #expect(firstParams?["text"] as? String == "")
        #expect(firstParams?["type"] as? String == "typed")
        #expect(lastParams?["text"] as? String == "Chat Question Answer Returned")
    }

    @Test
    func askQuestion_answer_failure_callsHandleError() {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [.failure(ChatError.apiUnavailable)]
        var chatError: ChatError?
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { error in
                chatError = error
            }
        )
        sut.latestQuestion = "This is the question"
        sut.askQuestion(.typed())

        #expect(sut.cellModels.count == 1)
        #expect(sut.cellModels.first?.type == .question)
        #expect(chatError == .apiUnavailable)
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func askQuestion_question_failure_callsHandleError() {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .failure(ChatError.authenticationError)
        var chatError: ChatError?
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { error in
                chatError = error
            }
        )
        sut.latestQuestion = "This is the question"
        sut.askQuestion(.typed())

        #expect(chatError == .authenticationError)
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func askQuestionWithPII_showValidationAlert() {
        let mockChatService = MockChatService()
        let mockAnalyticsService = MockAnalyticsService()
        mockChatService._stubbedQuestionResult = .failure(ChatError.pageNotFound)
        var chatError: ChatError?
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { error in
                chatError = error
            }
        )
        sut.latestQuestion = "My e-mail is steve@apple.com"

        #expect(sut.showValidationAlert == false)
        #expect(sut.validationAlertDetails.title == "Validation error")
        sut.askQuestion(.typed())

        #expect(sut.cellModels.count == 0)
        #expect(chatError == nil)
        #expect(sut.validationAlertDetails.title == "Personal data")
        #expect(sut.showValidationAlert == true)
        #expect(!sut.latestQuestion.isEmpty)
        #expect(mockAnalyticsService._trackedEvents.count == 0)
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func askQuestion_validationError_showValidationAlert() {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .failure(ChatError.validationError)
        var chatError: ChatError?
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { error in
                chatError = error
            }
        )
        sut.latestQuestion = "This is the question"

        #expect(sut.showValidationAlert == false)
        #expect(sut.validationAlertDetails.title == "Validation error")
        sut.askQuestion(.typed())

        #expect(sut.cellModels.count == 0)
        #expect(chatError == nil)
        #expect(sut.validationAlertDetails.title == "Personal data")
        #expect(sut.showValidationAlert == true)
        #expect(!sut.latestQuestion.isEmpty)
        #expect(sut.showExampleQuestions == false)
    }
    
    @Test
    func askQuestion_requestInFlight_ignoresMultipleSubsequentQuestions() {
        let mockChatService = MockChatService()
        mockChatService._shouldHoldQuestionCompletetion = true
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.askQuestion(.suggestion(question: "First Question"))
        sut.askQuestion(.suggestion(question: "Second Question"))
        sut.askQuestion(.suggestion(question: "Third Question"))
        
        #expect(mockChatService._receivedQuestions == ["First Question"])
        #expect(sut.cellModels.filter { $0.type == .question }.count == 1)
    }
    
    @Test
    func askQuestion_answerReturned_allowNextQuestion() {
        let mockChatService = MockChatService()
        mockChatService._shouldHoldQuestionCompletetion = true
        mockChatService._stubbedAnswerResults = [.success(.answeredAnswer)]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.askQuestion(.suggestion(question: "First Question"))
        mockChatService._receivedQuestionCompletion?(.success(.pendingQuestion))
        sut.askQuestion(.suggestion(question: "Second Question"))
        
        #expect(mockChatService._receivedQuestions == ["First Question", "Second Question"])
    }
    
    @Test
    func askQuestion_questionFailure_allowNextQuestion() {
        let mockChatService = MockChatService()
        mockChatService._shouldHoldQuestionCompletetion = true
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.askQuestion(.suggestion(question: "First Question"))
        mockChatService._receivedQuestionCompletion?(.failure(.apiUnavailable))
        sut.askQuestion(.suggestion(question: "Second Question"))
        
        #expect(mockChatService._receivedQuestions == ["First Question", "Second Question"])
    }
    
    @Test
    func newChat_afterAnswerReturned_allowsExampleQuestion() {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [.success(.answeredAnswer)]
        let configService = MockAppConfigService()
        configService._stubbedChatExampleQuestions = ["First question"]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: configService,
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.askQuestion(.suggestion(question: "First Question"))
        sut.newChat()
        #expect(sut.showExampleQuestions == true)
        sut.askQuestion(.suggestion(question: "Second Question"))

        #expect(mockChatService._receivedQuestions == ["First Question", "Second Question"])
    }

    @Test
    func loadHistory_success_createsCorrectCellModels() throws {
        let mockChatService = MockChatService()
        let conversationId = "conversationId"
        let createdAt = "\(Date())"
        let answerOne = Answer(
            createdAt: createdAt,
            id: "12345",
            message: "This is answer one",
            sources: nil
        )
        let answerTwo = Answer(
            createdAt: createdAt,
            id: "67890",
            message: "This is answer two",
            sources: nil
        )

        let aqOne = AnsweredQuestion(
            answer: answerOne,
            conversationId: conversationId,
            createdAt: createdAt,
            id: "1",
            message: "First question"
        )

        let aqTwo = AnsweredQuestion(
            answer: answerTwo,
            conversationId: conversationId,
            createdAt: createdAt,
            id: "2",
            message: "Next question"
        )

        let pendingQuestion = PendingQuestion(
            answerUrl: "https://www.example.com",
            conversationId: conversationId,
            createdAt: createdAt,
            id: "78910",
            message: "This is the pending question"
        )

        let history = History(
            pendingQuestion: pendingQuestion,
            answeredQuestions: [aqOne, aqTwo],
            createdAt: createdAt,
            id: "4456")

        mockChatService._stubbedConversationId = "12345"
        mockChatService._stubbedHistoryResult = .success(history)
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)

        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.loadHistory()
        try #require(sut.cellModels.count == 6)
        #expect(sut.cellModels[0].type == .intro)
        #expect(sut.cellModels[1].type == .question)
        #expect(sut.cellModels[2].type == .answer)
        #expect(sut.cellModels[3].type == .question)
        #expect(sut.cellModels[4].type == .answer)
        #expect(sut.cellModels[5].type == .question)
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func loadHistory_error_callsHandleError() {
        let mockChatService = MockChatService()
        mockChatService._stubbedConversationId = "12345"
        mockChatService._stubbedHistoryResult = .failure(ChatError.apiUnavailable)
        var chatError: ChatError?
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { error in
                chatError = error
            }
        )

        sut.loadHistory()
        #expect(sut.cellModels.count == 0)
        #expect(chatError == .apiUnavailable)
    }

    @Test
    func loadHistory_pageNotFoundError_clearsConversation() {
        let mockChatService = MockChatService()
        mockChatService._stubbedConversationId = "12345"
        mockChatService._stubbedHistoryResult = .failure(ChatError.pageNotFound)
        var chatError: ChatError?
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { error in
                chatError = error
            }
        )

        #expect(mockChatService.currentConversationId == "12345")
        sut.loadHistory()
        #expect(sut.cellModels.count == 1)
        #expect(chatError == nil)
        #expect(mockChatService.currentConversationId == nil)
        // Example questions not present in config
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func newChat_clearsHistory() {
        let mockChatService = MockChatService()

        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.cellModels = [.gettingAnswer]

        sut.newChat()
        #expect(mockChatService._clearHistoryCalled)
    }

    @Test
    func newChat_emptyExampleQuestions_doesntShowQuestions() {
        let configService = MockAppConfigService()
        configService._stubbedChatExampleQuestions = []
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: MockAnalyticsService(),
            configService: configService,
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.newChat()
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func newChat_nilExampleQuestions_doesntShowQuestions() {
        let configService = MockAppConfigService()
        configService._stubbedChatExampleQuestions = nil
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: MockAnalyticsService(),
            configService: configService,
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.newChat()
        #expect(sut.showExampleQuestions == false)
    }

    @Test
    func newChat_exampleQuestions_showsQuestions() {
        let configService = MockAppConfigService()
        configService._stubbedChatExampleQuestions = ["First question"]
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: MockAnalyticsService(),
            configService: configService,
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.newChat()
        #expect(sut.showExampleQuestions == true)
    }

    @Test
    func openAboutURL_opensURLAndtracksEvent() async {
        await confirmation() { confirmation in
            let mockAnalyticsService = MockAnalyticsService()
            let sut = ChatViewModel(
                chatService: MockChatService(),
                analyticsService: mockAnalyticsService,
                configService: MockAppConfigService(),
                openURLAction: { _ in confirmation() },
                handleError: { _ in }
            )

            sut.openAboutURL()
            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "About")
        }
    }

    @Test
    func openFeedbackURL_opensURLAndtracksEvent() async {
        await confirmation() { confirmation in
            let mockAnalyticsService = MockAnalyticsService()
            let sut = ChatViewModel(
                chatService: MockChatService(),
                analyticsService: mockAnalyticsService,
                configService: MockAppConfigService(),
                openURLAction: { _ in confirmation() },
                handleError: { _ in }
            )

            sut.openFeedbackURL()
            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Give feedback")
        }
    }

    @Test
    func openPrivacyURL_opensURLAndtracksEvent() async {
        await confirmation() { confirmation in
            let mockAnalyticsService = MockAnalyticsService()
            let sut = ChatViewModel(
                chatService: MockChatService(),
                analyticsService: mockAnalyticsService,
                configService: MockAppConfigService(),
                openURLAction: { _ in confirmation() },
                handleError: { _ in }
            )

            sut.openPrivacyURL()
            #expect(mockAnalyticsService._trackedEvents.count == 1)
            #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Privacy notice")
        }
    }

    @Test
    func trackMenuClearChatTap_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.trackMenuClearChatTap()
        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Clear chat")
    }

    @Test
    func trackMenuClearChatConfirmTap_tracksEvent() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.trackMenuClearChatConfirmTap()
        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["text"] as? String == "Yes, clear chat")
    }

    @Test
    func updateCharacterCount_remainingCharacter_updatesWarningText() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = """
            Lorem ipsum dolor sit amet consectetur adipiscing
            elit quisque faucibus ex sapien vitae pellentesque
            sem placerat in id cursus mi pretium tellus duis
            convallis tempus leo eu aenean sed diam urna tempor
            pulvinar vivamus fringillsss lacus nec metus biben
        """

        #expect(sut.warningText == nil)
        sut.updateCharacterCount()
        #expect(sut.warningText != nil)
        #expect(sut.errorText == nil)
    }

    @Test
    func updateCharacterCount_tooManyCharacter_updatesErrorText() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = """
            Lorem ipsum dolor sit amet consectetur adipiscing
            elit quisque faucibus ex sapien vitae pellentesque
            sem placerat in id cursus mi pretium tellus duis
            convallis tempus leo eu aenean sed diam urna tempor
            pulvinar vivamus fringillsss lacus nec metus biben
            pulvinar vivamus fringillsss lacus nec metus biben
            pulvinar vivamus fringillsss lacus nec metus biben
        """

        #expect(sut.errorText == nil)
        sut.updateCharacterCount()
        #expect(sut.errorText != nil)
        #expect(sut.warningText == nil)
    }

    @Test
    func updateCharacterCount_setsWarningAndErrorTextToNil() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ChatViewModel(
            chatService: MockChatService(),
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = "Lorem ipsum dolor sit amet consectetur adipiscing"

        sut.updateCharacterCount()
        #expect(sut.errorText == nil)
        #expect(sut.warningText == nil)
    }

    @Test
    func askQuestion_success_addsFeedbackForPendingQuestionId() throws {
        let mockChatService = MockChatService()
        let mockAnalyticsService = MockAnalyticsService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [.success(.answeredAnswer)]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: mockAnalyticsService,
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = "This is the question"
        sut.askQuestion(.typed())

        let feedbackViewModel = try #require(sut.cellModels.last?.feedbackViewModel)
        #expect(sut.cellModels.first?.feedbackViewModel == nil)
        feedbackViewModel.rate(isPositive: true)
        #expect(
            mockAnalyticsService._trackedEvents.last?.params?["question_id"] as? String ==
            "expectedPendingQuestionId"
        )
    }

    @Test
    func askQuestion_clearsPreviousFeedback() {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [
            .success(.answeredAnswer),
            .success(.answeredAnswer)
        ]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )
        sut.latestQuestion = "First question"
        sut.askQuestion(.typed())
        let firstAnswer = sut.cellModels.last
        sut.latestQuestion = "Second question"
        sut.askQuestion(.typed())

        #expect(firstAnswer?.feedbackViewModel == nil)
        #expect(sut.cellModels.last?.feedbackViewModel != nil)
        #expect(sut.cellModels.filter { $0.feedbackViewModel != nil }.count == 1)
    }

    @Test
    func loadHistory_answersHaveNoFeedback() {
        let mockChatService = MockChatService()
        let answeredQuestion = AnsweredQuestion(
            answer: .answeredAnswer,
            conversationId: "conversationId",
            createdAt: "\(Date())",
            id: "1",
            message: "First question"
        )
        mockChatService._stubbedConversationId = "conversationId"
        mockChatService._stubbedHistoryResult = .success(
            History(
                pendingQuestion: nil,
                answeredQuestions: [answeredQuestion],
                createdAt: "\(Date())",
                id: "4456"
            )
        )
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in }
        )

        sut.loadHistory()

        #expect(sut.cellModels.contains { $0.type == .answer })
        #expect(sut.cellModels.allSatisfy { $0.feedbackViewModel == nil })
    }

    @Test(arguments: [0, 1, 2])
    func chatDidDisappear_clearsFeedbackInEveryState(taps: Int) throws {
        let sut = makeAnsweredChatViewModel()
        let answer = try #require(sut.cellModels.last)
        let feedbackViewModel = try #require(answer.feedbackViewModel)
        if taps > 0 { feedbackViewModel.rate(isPositive: true) }
        if taps > 1 { feedbackViewModel.openSurvey() }

        sut.chatDidDisappear()

        #expect(answer.feedbackViewModel == nil)
    }

    @Test
    func chatDidDisappear_afterOpeningLink_keepsFeedback() throws {
        let sut = makeAnsweredChatViewModel()
        let answer = try #require(sut.cellModels.last)
        try #require(answer.feedbackViewModel).rate(isPositive: false)

        answer.openURL(url: URL(string: "https://www.gov.uk")!, type: .sourceLink)
        sut.chatDidDisappear()
        #expect(answer.feedbackViewModel != nil)

        sut.chatDidAppear()
        sut.chatDidDisappear()
        #expect(answer.feedbackViewModel == nil)
    }

    @Test
    func chatDidDisappear_afterOpeningMenuLink_keepsFeedback() throws {
        let sut = makeAnsweredChatViewModel()
        let answer = try #require(sut.cellModels.last)

        sut.openAboutURL()
        sut.chatDidDisappear()

        #expect(answer.feedbackViewModel != nil)
    }

    @Test
    func appDidEnterBackground_clearsFeedback() throws {
        let sut = makeAnsweredChatViewModel()
        let answer = try #require(sut.cellModels.last)
        sut.openAboutURL()

        sut.appDidEnterBackground()

        #expect(answer.feedbackViewModel == nil)
    }

    @Test
    func feedbackConfirmed_scrollsToBottom() throws {
        let sut = makeAnsweredChatViewModel(scheduleFeedbackConfirmation: { $0() })
        let feedbackViewModel = try #require(sut.cellModels.last?.feedbackViewModel)
        sut.scrollToBottom = false

        feedbackViewModel.rate(isPositive: true)
        feedbackViewModel.openSurvey()

        #expect(feedbackViewModel.state == .confirmed)
        #expect(sut.scrollToBottom)
    }

    private func makeAnsweredChatViewModel(
        scheduleFeedbackConfirmation: @escaping ChatFeedbackViewModel.ConfirmationScheduler = { _ in }
    ) -> ChatViewModel {
        let mockChatService = MockChatService()
        mockChatService._stubbedQuestionResult = .success(.pendingQuestion)
        mockChatService._stubbedAnswerResults = [.success(.answeredAnswer)]
        let sut = ChatViewModel(
            chatService: mockChatService,
            analyticsService: MockAnalyticsService(),
            configService: MockAppConfigService(),
            openURLAction: { _ in },
            handleError: { _ in },
            scheduleFeedbackConfirmation: scheduleFeedbackConfirmation
        )
        sut.latestQuestion = "This is the question"
        sut.askQuestion(.typed())
        return sut
    }
}
