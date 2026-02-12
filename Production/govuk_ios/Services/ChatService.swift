import Foundation
import GovKit

protocol ChatServiceInterface {
    // MARK: - Service
    func askQuestion(_ question: String,
                     completion: @escaping (ChatQuestionResult) -> Void)
    func pollForAnswer(_ pendingQuestion: PendingQuestion,
                       completion: @escaping (ChatAnswerResult) -> Void)
    func chatHistory(conversationId: String,
                     completion: @escaping (ChatHistoryResult) -> Void)
    func clearHistory()
    func clear()

    // MARK: - Configuration
    var currentConversationId: String? { get }
    var isEnabled: Bool { get }
    var privacyPolicy: URL { get }
    var termsAndConditions: URL { get }
    var about: URL { get }
    var feedback: URL { get }
    var chatOnboardingSeen: Bool { get set }
}

// MARK: - Service
final class ChatService: ChatServiceInterface {
    private let serviceClient: ChatServiceClientInterface
    private let chatRepository: ChatRepositoryInterface
    private let configService: AppConfigServiceInterface
    private let userDefaultsService: UserDefaultsServiceInterface

    var currentConversationId: String? {
        chatRepository.fetchConversation()
    }

    init(serviceClient: ChatServiceClientInterface,
         chatRepository: ChatRepositoryInterface,
         configService: AppConfigServiceInterface,
         userDefaultsService: UserDefaultsServiceInterface) {
        self.serviceClient = serviceClient
        self.chatRepository = chatRepository
        self.configService = configService
        self.userDefaultsService = userDefaultsService
    }

    func askQuestion(_ question: String,
                     completion: @escaping (ChatQuestionResult) -> Void) {
        serviceClient.askQuestion(
            question,
            conversationId: currentConversationId,
            completion: { [weak self] result in
                switch result {
                case .success(let pendingQuestion):
                    self?.setConversationId(pendingQuestion.conversationId)
                    completion(.success(pendingQuestion))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func pollForAnswer(_ pendingQuestion: PendingQuestion,
                       completion: @escaping (ChatAnswerResult) -> Void) {
        serviceClient.fetchAnswer(
            conversationId: pendingQuestion.conversationId,
            questionId: pendingQuestion.id,
            completion: { [weak self] result in
                guard let self else {
                    return
                }
                switch result {
                case .success(let answer):
                    guard answer.answerAvailable else {
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + (self.pollingInterval)
                        ) {
                            self.pollForAnswer(
                                pendingQuestion,
                                completion: completion
                            )
                        }
                        return
                    }
                    completion(.success(answer))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func chatHistory(conversationId: String,
                     completion: @escaping (ChatHistoryResult) -> Void) {
        setConversationId(conversationId)
        serviceClient.fetchHistory(
            conversationId: conversationId,
            completion: { result in
                switch result {
                case .success(let history):
                    completion(.success(history))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }

    func clearHistory() {
        setConversationId(nil)
    }

    func clear() {
        chatOnboardingSeen = false
    }

    private func setConversationId(_ conversationId: String?) {
        guard conversationId != currentConversationId else { return }
        chatRepository.saveConversation(conversationId)
    }
}

// MARK: - Configuration
extension ChatService {
    private var pollingInterval: TimeInterval {
        configService.chatPollIntervalSeconds
    }

    var isEnabled: Bool {
        #if STAGING
        configService.isFeatureEnabled(key: .chat)
        #else
        false
        #endif
    }

    var chatOnboardingSeen: Bool {
        get {
            userDefaultsService.bool(forKey: .chatOnboardingSeen)
        } set {
            if newValue {
                userDefaultsService.set(bool: newValue, forKey: .chatOnboardingSeen)
            } else {
                userDefaultsService.removeObject(forKey: .chatOnboardingSeen)
            }
        }
    }

    var privacyPolicy: URL {
        configService.chatUrls?.privacyNotice ?? Constants.API.defaultChatPrivacyPolicyUrl
    }

    var termsAndConditions: URL {
        configService.chatUrls?.termsAndConditions ?? Constants.API.defaultChatTermsUrl
    }

    var about: URL {
        configService.chatUrls?.about ?? Constants.API.defaultChatAboutUrl
    }

    var feedback: URL {
        configService.chatUrls?.feedback ?? Constants.API.defaultChatFeedbackUrl
    }
}
