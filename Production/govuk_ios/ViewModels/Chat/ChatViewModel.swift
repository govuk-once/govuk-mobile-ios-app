import SwiftUI
import GovKit
import GovKitUI

// swiftlint:disable:next type_body_length
class ChatViewModel: ObservableObject {
    private let chatService: ChatServiceInterface
    private let analyticsService: AnalyticsServiceInterface
    let maxCharacters = 300
    private let openURLAction: (URL) -> Void
    private let handleError: (ChatError) -> Void
    private var shouldLoadHistory: Bool = true
    // Default values will be overridden
    private(set) var validationAlertDetails = AlertDetails(
        title: "Validation error",
        message: "",
        buttonTitle: "OK"
    )

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
         openURLAction: @escaping (URL) -> Void,
         handleError: @escaping (ChatError) -> Void) {
        self.chatService = chatService
        self.analyticsService = analyticsService
        self.openURLAction = openURLAction
        self.handleError = handleError
    }

    func askQuestion(_ question: String? = nil,
                     completion: ((Bool) -> Void)? = nil) {
        let localQuestion = (question ?? latestQuestion)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !containsPII(localQuestion) else {
            setPersonalDataValidationAlertDetails()
            showValidationAlert = true
            return
        }
        trackAskQuestionSubmission()
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
            self?.requestInFlight = false
            self?.removeCellModel(.loadingQuestion)
            switch result {
            case .success(let pendingQuestion):
                self?.latestQuestionID = currentQuestionModel.id
                self?.latestQuestion = ""
                self?.pollForAnswer(pendingQuestion)
                completion?(true)
            case .failure(let error):
                self?.requestInFlight = false
                if error == .validationError {
                    self?.setPersonalDataValidationAlertDetails()
                    self?.showValidationAlert = true
                    self?.removeCellModel(currentQuestionModel)
                } else {
                    self?.processError(error)
                    self?.latestQuestion = ""
                    completion?(false)
                }
            }
        }
    }

    private func pollForAnswer(_ question: PendingQuestion) {
        requestInFlight = true
        addCellModels([.gettingAnswer])
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
                scrollToTop = true
                addCellModels([cellModel])
                announceAnswerReceived()
            case .failure(let error):
                processError(error)
            }
            trackAnswerResponse()
        }
    }

    func loadHistory() {
        guard let conversationId = chatService.currentConversationId else {
            cellModels.removeAll()
            appendIntroMessage(animate: true)
            return
        }
        guard shouldLoadHistory else {
            return
        }
        requestInFlight = true
        chatService.chatHistory(
            conversationId: conversationId
        ) { [weak self] result in
            self?.requestInFlight = false
            switch result {
            case .success(let answers):
                self?.shouldLoadHistory = false
                self?.handleHistoryResponse(answers)
            case .failure(let error):
                if error == .pageNotFound {
                    self?.chatService.clearHistory()
                    self?.cellModels.removeAll()
                    self?.appendIntroMessage(animate: true)
                } else {
                    self?.processError(error)
                }
            }
            self?.scrollToBottom = true
        }
    }

    private func processError(_ error: ChatError) {
        shouldLoadHistory = error != .authenticationError
        handleError(error)
    }

    private func appendIntroMessage(animate: Bool) {
        let introMessage = Intro(
            message: String.chat.localized("introMessage")
        )
        let model =
            ChatCellViewModel(
                intro: introMessage,
                analyticsService: analyticsService
            )
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
    }

    private func removeCellModel(_ model: ChatCellViewModel) {
        model.isVisible = false
        cellModels.removeAll(where: { $0.id == model.id })
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
        if let pendingQuestion = history.pendingQuestion {
            cellModels.append(ChatCellViewModel(
                question: pendingQuestion,
                analyticsService: analyticsService)
            )
            pollForAnswer(pendingQuestion)
        }
    }

    private func containsPII(_ input: String) -> Bool {
        RegexValidator.pii.validate(input: input)
    }

    @objc
    func newChat() {
        cellModels.removeAll()
        chatService.clearHistory()
        appendIntroMessage(animate: true)
    }

    func openAboutURL() {
        trackMenuTap(String.chat.localized("aboutMenuTitle"))
        openURLAction(chatService.about)
    }

    func openPrivacyURL() {
        trackMenuTap(String.chat.localized("privacyMenuTitle"))
        openURLAction(chatService.privacyPolicy)
    }

    func openFeedbackURL() {
        trackMenuTap(String.chat.localized("feedbackMenuTitle"))
        openURLAction(chatService.feedback)
    }

    func trackScreen(screen: TrackableScreen) {
        analyticsService.track(screen: screen)
    }

    func trackMenuClearChatTap() {
        let event = AppEvent.chatActionButtonFunction(
            text: String.chat.localized("clearMenuTitle"),
            action: "Clear Chat Tapped"
        )
        analyticsService.track(event: event)
    }

    func trackMenuClearChatConfirmTap() {
        let event = AppEvent.chatActionButtonFunction(
            text: String.chat.localized("clearAlertConfirmTitle"),
            action: "Clear Chat Yes Tapped"
        )
        analyticsService.track(event: event)
    }

    func trackMenuClearChatDenyTap() {
        let event = AppEvent.chatActionButtonFunction(
            text: String.chat.localized("clearAlertDenyTitle"),
            action: "Clear Chat No Tapped"
        )
        analyticsService.track(event: event)
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

    private func trackMenuTap(_ itemTitle: String) {
        let event = AppEvent.buttonNavigation(
            text: itemTitle,
            external: true
        )
        analyticsService.track(event: event)
    }

    private func trackAskQuestionSubmission() {
        let event = AppEvent.chatAskQuestion()
        analyticsService.track(event: event)
    }

    private func trackAnswerResponse() {
        let event = AppEvent.function(
            text: "Chat Question Answer Returned",
            type: "ChatQuestionAnswerReturned",
            section: "Chat",
            action: "Chat Question Answer Returned"
        )
        analyticsService.track(event: event)
    }

    private func setPersonalDataValidationAlertDetails() {
        validationAlertDetails = AlertDetails(
            title: String.chat.localized("personalDataValidationTitle"),
            message: String.chat.localized("personalDataValidationErrorText"),
            buttonTitle: String.common.localized("ok")
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
}
