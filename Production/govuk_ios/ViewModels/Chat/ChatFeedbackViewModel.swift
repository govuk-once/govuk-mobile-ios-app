import Foundation
import GovKit

final class ChatFeedbackViewModel: ObservableObject {
    typealias ConfirmationScheduler = (@escaping () -> Void) -> Void

    private static let confirmationDelay: TimeInterval = 0.5
    static let defaultConfirmationScheduler: ConfirmationScheduler = { confirm in
        DispatchQueue.main.asyncAfter(deadline: .now() + confirmationDelay, execute: confirm)
    }

    @Published private(set) var state: ChatFeedbackState = .unrated

    private let questionId: String
    private let analyticsService: AnalyticsServiceInterface
    private let scheduleConfirmation: ConfirmationScheduler
    private let onConfirmed: () -> Void

    init(questionId: String,
         analyticsService: AnalyticsServiceInterface,
         scheduleConfirmation: @escaping ConfirmationScheduler =
            ChatFeedbackViewModel.defaultConfirmationScheduler,
         onConfirmed: @escaping () -> Void = { }) {
        self.questionId = questionId
        self.analyticsService = analyticsService
        self.scheduleConfirmation = scheduleConfirmation
        self.onConfirmed = onConfirmed
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
        state = .rated(isPositive: isPositive)
        analyticsService.track(
            event: .chatFeedbackIcon(
                isPositive: isPositive,
                questionId: questionId
            )
        )
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
    }
}
