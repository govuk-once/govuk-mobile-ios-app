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
    private let accessibilityAnnouncer: AccessibilityAnnouncerServiceInterface
    private let scheduleConfirmation: ConfirmationScheduler
    private let notificationCenter: NotificationCenter
    private let onConfirmed: () -> Void
    private var surveyDismissedObserverToken: Any?

    init(questionId: String,
         analyticsService: AnalyticsServiceInterface,
         accessibilityAnnouncer: AccessibilityAnnouncerServiceInterface =
            AccessibilityAnnouncerService(),
         scheduleConfirmation: @escaping ConfirmationScheduler =
            ChatFeedbackViewModel.defaultConfirmationScheduler,
         notificationCenter: NotificationCenter = .default,
         onConfirmed: @escaping () -> Void = { /* No-op */ }) {
        self.questionId = questionId
        self.analyticsService = analyticsService
        self.accessibilityAnnouncer = accessibilityAnnouncer
        self.scheduleConfirmation = scheduleConfirmation
        self.notificationCenter = notificationCenter
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
        case .unrated, .confirmed:
            return nil
        }
    }

    func rate(isPositive: Bool) {
        guard state == .unrated else { return }
        // Without analytics consent AnalyticsService drops this event, so the rating isn't
        // recorded anywhere. Recording ratings regardless of consent is planned Chat API work.
        analyticsService.track(
            event: .chatFeedbackIcon(
                isPositive: isPositive,
                questionId: questionId
            )
        )
        if isLinkVisible {
            state = .rated(isPositive: isPositive)
            accessibilityAnnouncer.announce(
                String(localized: isPositive ?
                    .Chat.feedbackHelpfulSelectedAccessibilityAnnouncement :
                    .Chat.feedbackNotHelpfulSelectedAccessibilityAnnouncement)
            )
        } else {
            state = .confirmed
            onConfirmed()
            confirmationFocusRequests.send()
        }
    }

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
