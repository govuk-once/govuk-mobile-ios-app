import SwiftUI
import GovKit
import GovKitUI
import Combine

class ChatViewModel: ObservableObject {
    let chatService: ChatServiceInterface
    let analyticsService: AnalyticsServiceInterface
    private let configService: AppConfigServiceInterface
    let maxCharacters = 300
    let openURLAction: (URL) -> Void
    private let handleError: (ChatError) -> Void
    private let feedbackViewModelBuilder: ChatFeedbackViewModelBuilder
    private var shouldLoadHistory: Bool = true
    private var disclosureListeners = Set<AnyCancellable>()
    // Default values will be overridden
    private(set) var validationAlertDetails = AlertDetails(
        title: "Validation error",
        message: "",
        primaryButtonTitle: "OK"
    )
    let chatExampleQuestionsViewModel: ChatExampleQuestionsViewModel
    @Published var cellModels: [ChatCellViewModel] = []
    @Published var latestQuestion: String = ""
    @Published var scrollToBottom: Bool = false
    @Published var scrollToTop: Bool = false
    @Published var latestQuestionID: String = ""
    @Published var errorText: LocalizedStringKey?
    @Published var warningText: LocalizedStringKey?
    @Published var textViewHeight: CGFloat = 48.0
    @Published var requestInFlight: Bool = false
    @Published var showValidationAlert: Bool = false
    @Published var showProgressView: Bool = false
    @Published var showExampleQuestions: Bool = false

    var absoluteRemainingCharacters: Int {
        abs(maxCharacters - latestQuestion.count)
    }

    var shouldDisableSend: Bool {
        let question = latestQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        return question.count == 0 ||
        (question.count > maxCharacters) ||
        requestInFlight
    }

    var currentConversationExists: Bool {
        chatService.currentConversationId != nil
    }

    init(chatService: ChatServiceInterface,
         analyticsService: AnalyticsServiceInterface,
         configService: AppConfigServiceInterface,
         openURLAction: @escaping (URL) -> Void,
         handleError: @escaping (ChatError) -> Void,
         scheduleFeedbackConfirmation: @escaping ChatFeedbackViewModel.ConfirmationScheduler =
            ChatFeedbackViewModel.defaultConfirmationScheduler) {
        self.chatService = chatService
        self.analyticsService = analyticsService
        self.configService = configService
        self.openURLAction = openURLAction
        self.handleError = handleError
        self.feedbackViewModelBuilder = ChatFeedbackViewModelBuilder(
            chatService: chatService,
            analyticsService: analyticsService,
            scheduleConfirmation: scheduleFeedbackConfirmation
        )
        self.chatExampleQuestionsViewModel = .init(
            analyticsService: analyticsService,
            configService: configService
        )
    }

    func askQuestion(_ questionRequest: AskQuestionRequest,
                     completion: ((Bool) -> Void)? = nil) {
        guard !requestInFlight else { return }
        showExampleQuestions = false
        let localQuestion = (questionRequest.question ?? latestQuestion)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !containsPII(localQuestion) else {
            setPersonalDataValidationAlertDetails()
            showValidationAlert = true
            return
        }
        trackAskQuestionSubmission(type: questionRequest.type.rawValue)
        clearFeedback()
        errorText = nil
        warningText = nil
        let currentQuestionModel = ChatCellViewModel(
            message: localQuestion,
            id: UUID().uuidString,
            type: .question,
            analyticsService: analyticsService
        )
        addCellModels([
            currentQuestionModel,
            .loadingQuestion])
        scrollToBottom = true
        requestInFlight = true
        chatService.askQuestion(localQuestion) { [weak self] result in
            self?.removeCellModel(.loadingQuestion)
            switch result {
            case .success(let pendingQuestion):
                self?.latestQuestionID = currentQuestionModel.id
                self?.latestQuestion = ""
                self?.pollForAnswer(pendingQuestion)
                completion?(true)
            case .failure(let error):
                self?.requestInFlight = false
                switch error {
                case .validationError:
                    self?.setPersonalDataValidationAlertDetails()
                    self?.showValidationAlert = true
                    self?.removeCellModel(currentQuestionModel)
                case .authenticationError:
                    self?.removeCellModel(currentQuestionModel)
                    self?.processError(error)
                    completion?(false)
                default:
                    self?.latestQuestion = ""
                    self?.processError(error)
                    completion?(false)
                }
            }
        }
    }

    private func pollForAnswer(_ question: PendingQuestion) {
        requestInFlight = true
        addCellModels([.gettingAnswer])
        announceGeneratingAnswer()
        chatService.pollForAnswer(question) { [weak self] result in
            guard let self else { return }
            removeCellModel(.gettingAnswer)
            requestInFlight = false
            switch result {
            case .success(let answer):
                let cellModel = ChatCellViewModel(
                    answer: answer,
                    openURLAction: openURLAction,
                    analyticsService: analyticsService
                )
                cellModel.feedbackViewModel = makeFeedbackViewModel(
                    questionId: question.id,
                    conversationId: question.conversationId,
                    answer: answer
                )
                scrollToTop = true
                addCellModels([cellModel])
                announceAnswerReceived()
            case .failure(let error):
                processError(error)
            }
            trackAnswerResponse()
        }
    }

    private func clearFeedback() {
        cellModels.forEach { $0.feedbackViewModel = nil }
    }

    private func makeFeedbackViewModel(questionId: String,
                                       conversationId: String,
                                       answer: Answer) -> ChatFeedbackViewModel? {
        feedbackViewModelBuilder.makeViewModel(
            questionId: questionId,
            conversationId: conversationId,
            answer: answer,
            confirmedAction: { [weak self] in
                self?.scrollToBottom = true
            },
            errorAction: { [weak self] error in
                self?.processError(error)
            }
        )
    }

    private func processError(_ error: ChatError) {
        shouldLoadHistory = error != .authenticationError
        handleError(error)
    }

    private func containsPII(_ input: String) -> Bool {
        RegexValidator.pii.validate(input: input)
    }

    @objc
    func newChat() {
        cellModels.removeAll()
        chatService.clearHistory()
        appendIntroMessage(animate: true)
        scrollToTop = true
        showExampleQuestions = exampleQuestionsPresent
    }

    func updateCharacterCount() {
        if latestQuestion.count > maxCharacters {
            errorText = LocalizedStringKey(
                "tooManyCharactersTitle.\(absoluteRemainingCharacters)"
            )
            warningText = nil
        } else if latestQuestion.count >= (maxCharacters - 50) {
            warningText = LocalizedStringKey(
                "remainingCharactersTitle.\(absoluteRemainingCharacters)"
            )
            errorText = nil
        } else {
            errorText = nil
            warningText = nil
        }
    }

    private var exampleQuestionsPresent: Bool {
        guard let questions = configService.chatExampleQuestions else {
            return false
        }
        return !questions.isEmpty
    }

    private func setPersonalDataValidationAlertDetails() {
        validationAlertDetails = AlertDetails(
            title: String.chat.localized("personalDataValidationTitle"),
            message: String.chat.localized("personalDataValidationErrorText"),
            primaryButtonTitle: String.common.localized("ok")
        )
    }

    private func announceAnswerReceived() {
        DispatchQueue.main.async {
            UIAccessibility.post(
                notification: .announcement,
                argument: String.chat.localized("answerReceivedAccessibilityTitle")
            )
        }
    }

    private func announceGeneratingAnswer() {
        DispatchQueue.main.async {
            UIAccessibility.post(
                notification: .announcement,
                argument: String(localized: .Chat.generatingAnswerAccessibilityTitle)
            )
        }
    }
}

// MARK: History
extension ChatViewModel {
    func loadHistory() {
        guard shouldLoadHistory else { return }
        guard let conversationId = chatService.currentConversationId else {
            cellModels.removeAll()
            appendIntroMessage(animate: true)
            shouldLoadHistory = false
            showExampleQuestions = exampleQuestionsPresent
            return
        }
        requestInFlight = true
        showProgressView = true
        chatService.chatHistory(
            conversationId: conversationId
        ) { [weak self] result in
            guard let self else { return }

            requestInFlight = false
            showProgressView = false
            switch result {
            case .success(let answers):
                shouldLoadHistory = false
                handleHistoryResponse(answers)
            case .failure(let error):
                if error == .pageNotFound {
                    chatService.clearHistory()
                    cellModels.removeAll()
                    appendIntroMessage(animate: true)
                    showExampleQuestions = exampleQuestionsPresent
                } else {
                    processError(error)
                }
            }
            scrollToBottom = true
            listenForDisclosure()
        }
    }

    private func handleHistoryResponse(_ history: History) {
        cellModels.removeAll()
        appendIntroMessage(animate: false)
        let answers = history.answeredQuestions
        answers.forEach { answeredQuestion in
            let question = ChatCellViewModel(answeredQuestion: answeredQuestion,
                                             analyticsService: analyticsService)
            question.isVisible = true
            cellModels.append(question)
            let answer = ChatCellViewModel(
                answer: answeredQuestion.answer,
                openURLAction: openURLAction,
                analyticsService: analyticsService
            )
            answer.isVisible = true
            cellModels.append(answer)
        }
        if history.pendingQuestion == nil,
           let latestAnsweredQuestion = answers.last {
            cellModels.last?.feedbackViewModel = makeFeedbackViewModel(
                questionId: latestAnsweredQuestion.id,
                conversationId: latestAnsweredQuestion.conversationId,
                answer: latestAnsweredQuestion.answer
            )
        }
        if let pendingQuestion = history.pendingQuestion {
            cellModels.append(ChatCellViewModel(
                question: pendingQuestion,
                analyticsService: analyticsService)
            )
            pollForAnswer(pendingQuestion)
        }
        showExampleQuestions = shouldShowExampleQuestions(
            pendingQuestion: history.pendingQuestion,
            answers: answers
        )
    }

    func shouldShowExampleQuestions(
        pendingQuestion: PendingQuestion?,
        answers: [AnsweredQuestion]
    ) -> Bool {
        guard pendingQuestion == nil else { return false }
        guard answers.isEmpty else { return false }
        return exampleQuestionsPresent
    }
}

// MARK: Cell models
extension ChatViewModel {
    private func appendIntroMessage(animate: Bool) {
        let introMessage = Intro(
            message: String.chat.localized("introMessage")
        )
        let model = ChatCellViewModel(
            intro: introMessage,
            analyticsService: analyticsService
        )
        latestQuestionID = model.id
        if animate {
            addCellModels([model])
        } else {
            model.isVisible = true
            cellModels.append(model)
        }
    }

    private func addCellModels(_ models: [ChatCellViewModel]) {
        cellModels.append(contentsOf: models)
        for model in models {
            DispatchQueue.main.async {
                model.isVisible = true
            }
        }
        listenForDisclosure()
    }

    private func listenForDisclosure() {
        disclosureListeners.removeAll()
        cellModels.last?.$isSourceListExpanded
            .sink { value in
                Task { @MainActor [weak self] in
                    // wait for menu expansion before scrolling
                    try await Task.sleep(for: .seconds(0.05))
                    self?.scrollToBottom = value
                }
            }
            .store(in: &disclosureListeners)
    }

    private func removeCellModel(_ model: ChatCellViewModel) {
        model.isVisible = false
        cellModels.removeAll(where: { $0.id == model.id })
    }
}
