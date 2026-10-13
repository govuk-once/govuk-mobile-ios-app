import Foundation
import Combine
import GovKit

final class ChatFeedbackViewModel: ObservableObject {
    typealias ConfirmationScheduler = (@escaping () -> Void) -> Void

    private static let confirmationDelay: TimeInterval = 0.5
    static let defaultConfirmationScheduler: ConfirmationScheduler = { confirm in
        DispatchQueue.main.asyncAfter(deadline: .now() + confirmationDelay, execute: confirm)
    }

    @Published private(set) var state: ChatFeedbackState = .unrated
    let confirmationFocusRequests = PassthroughSubject<Void, Never>()

    private let questionId: String
    private let analyticsService: AnalyticsServiceInterface
    private let scheduleConfirmation: ConfirmationScheduler
    private let notificationCenter: NotificationCenter
    private let sendRating: (Bool, @escaping (Bool) -> Void) -> Void
    private let onConfirmed: () -> Void
    private var surveyDismissedObserverToken: Any?

    init(questionId: String,
         analyticsService: AnalyticsServiceInterface,
         scheduleConfirmation: @escaping ConfirmationScheduler =
            ChatFeedbackViewModel.defaultConfirmationScheduler,
         notificationCenter: NotificationCenter = .default,
         sendRating: @escaping (Bool, @escaping (Bool) -> Void) -> Void = { _, completion in
            completion(true)
         },
         onConfirmed: @escaping () -> Void = {
            /* no-op */
         }) {
        self.questionId = questionId
        self.analyticsService = analyticsService
        self.scheduleConfirmation = scheduleConfirmation
        self.notificationCenter = notificationCenter
        self.sendRating = sendRating
        self.onConfirmed = onConfirmed
        observeSurveyDismissal()
    }

    deinit {
        if let surveyDismissedObserverToken {
            notificationCenter.removeObserver(surveyDismissedObserverToken)
        }
    }

    var isLinkVisible: Bool {
        analyticsService.permissionState == .accepted
    }

    var selection: Bool? {
        switch state {
        case .rated(let isPositive), .surveyOpened(let isPositive):
            return isPositive
        case .unrated, .submitting, .confirmed:
            return nil
        }
    }

    @MainActor
    func rate(isPositive: Bool) {
        guard state == .unrated else { return }
        state = .submitting
        sendRating(isPositive) { [weak self] didSucceed in
            self?.handleRatingResult(isPositive: isPositive, didSucceed: didSucceed)
        }
    }

    @MainActor
    private func handleRatingResult(isPositive: Bool,
                                    didSucceed: Bool) {
        guard state == .submitting else { return }
        guard didSucceed else {
            state = .unrated
            return
        }
        analyticsService.track(
            event: .chatFeedbackIcon(
                isPositive: isPositive,
                questionId: questionId
            )
        )
        if isLinkVisible {
            state = .rated(isPositive: isPositive)
        } else {
            state = .confirmed
            onConfirmed()
            confirmationFocusRequests.send()
        }
    }

    @MainActor
    func openSurvey() {
        guard case .rated(let isPositive) = state,
              isLinkVisible
        else { return }
        state = .surveyOpened(isPositive: isPositive)
        analyticsService.track(
            event: .chatFeedbackLink(
                isPositive: isPositive,
                questionId: questionId
            )
        )
        scheduleConfirmation { [weak self] in
            self?.confirm()
        }
    }

    @MainActor
    private func confirm() {
        guard case .surveyOpened = state else { return }
        state = .confirmed
        onConfirmed()
        confirmationFocusRequests.send()
    }

    private func observeSurveyDismissal() {
        surveyDismissedObserverToken = notificationCenter.addObserver(
            forName: .qualtricsSurveyDismissed,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard self?.state == .confirmed else { return }
                self?.confirmationFocusRequests.send()
            }
        )
    }
}
