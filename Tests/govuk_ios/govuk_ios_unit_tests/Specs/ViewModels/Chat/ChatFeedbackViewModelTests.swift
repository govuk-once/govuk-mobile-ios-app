import Foundation
import Combine
import Testing
import GovKit

@testable import govuk_ios

@Suite
struct ChatFeedbackViewModelTests {

    @Test(arguments: [true, false])
    func rate_setsStateAndTracksIconEvent(isPositive: Bool) throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        sut.rate(isPositive: isPositive)

        #expect(sut.state == .rated(isPositive: isPositive))
        #expect(sut.selection == isPositive)
        try #require(mockAnalyticsService._trackedEvents.count == 1)
        let event = mockAnalyticsService._trackedEvents[0]
        #expect(event.name == "ChatFeedback")
        #expect(event.params?["text"] as? String == (isPositive ? "thumbs up" : "thumbs down"))
        #expect(event.params?["action"] as? String == "icon")
        #expect(event.params?["type"] as? String == "Feedback")
        #expect(event.params?["section"] as? String == "Chat")
        #expect(event.params?["questionId"] as? String == "questionId")
        #expect(event.params?["conversation_id"] == nil)
    }

    @Test(arguments: [
        (true, "Helpful, selected"),
        (false, "Not helpful, selected")
    ])
    func rate_withConsent_announcesSelection(isPositive: Bool, expectedAnnouncement: String) {
        let mockAccessibilityAnnouncer = MockAccessibilityAnnouncerService()
        let sut = makeSUT(accessibilityAnnouncer: mockAccessibilityAnnouncer)

        sut.rate(isPositive: isPositive)

        #expect(mockAccessibilityAnnouncer._receivedAnnounceValue == expectedAnnouncement)
    }

    @Test
    func rate_afterRating_isIgnored() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        sut.rate(isPositive: true)
        sut.rate(isPositive: true)
        sut.rate(isPositive: false)

        #expect(sut.state == .rated(isPositive: true))
        #expect(mockAnalyticsService._trackedEvents.count == 1)
    }

    @Test(arguments: [
        (AnalyticsPermissionState.accepted, true),
        (AnalyticsPermissionState.denied, false),
        (AnalyticsPermissionState.unknown, false)
    ])
    func isLinkVisible_followsConsent(permissionState: AnalyticsPermissionState,
                                      expected: Bool) {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = permissionState
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        #expect(sut.isLinkVisible == expected)
    }

    @Test(arguments: [true, false])
    func openSurvey_tracksLinkEvent(isPositive: Bool) throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        sut.rate(isPositive: isPositive)
        sut.openSurvey()

        #expect(sut.state == .surveyOpened(isPositive: isPositive))
        try #require(mockAnalyticsService._trackedEvents.count == 2)
        let event = mockAnalyticsService._trackedEvents[1]
        #expect(event.name == "ChatFeedback")
        #expect(
            event.params?["text"] as? String ==
            (isPositive ? "Say what went well" : "Say what went wrong")
        )
        #expect(event.params?["action"] as? String == "link")
        #expect(event.params?["type"] as? String == "Feedback")
        #expect(event.params?["section"] as? String == "Chat")
        #expect(event.params?["questionId"] as? String == "questionId")
        #expect(event.params?["conversation_id"] == nil)
    }

    @Test
    func openSurvey_beforeRating_isIgnored() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        sut.openSurvey()

        #expect(sut.state == .unrated)
        #expect(mockAnalyticsService._trackedEvents.isEmpty)
    }

    @Test(arguments: [true, false])
    func rate_withoutConsent_tracksEventAndConfirms(isPositive: Bool) {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = .denied
        let mockAccessibilityAnnouncer = MockAccessibilityAnnouncerService()
        var didConfirm = false
        let sut = makeSUT(
            analyticsService: mockAnalyticsService,
            accessibilityAnnouncer: mockAccessibilityAnnouncer,
            onConfirmed: { didConfirm = true }
        )

        sut.rate(isPositive: isPositive)
        sut.openSurvey()

        #expect(sut.state == .confirmed)
        #expect(sut.selection == nil)
        #expect(didConfirm)
        #expect(mockAnalyticsService._trackedEvents.count == 1)
        #expect(mockAnalyticsService._trackedEvents.first?.params?["action"] as? String == "icon")
        #expect(mockAccessibilityAnnouncer._receivedAnnounceValue == nil)
    }

    @Test
    func openSurvey_twice_tracksOnce() {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        sut.rate(isPositive: false)
        sut.openSurvey()
        sut.openSurvey()

        #expect(mockAnalyticsService._trackedEvents.count == 2)
    }

    @Test
    func openSurvey_confirmsOnlyWhenScheduledConfirmationRuns() throws {
        var scheduledConfirmation: (() -> Void)?
        var didConfirm = false
        let sut = makeSUT(
            scheduleConfirmation: { scheduledConfirmation = $0 },
            onConfirmed: { didConfirm = true }
        )

        sut.rate(isPositive: false)
        sut.openSurvey()

        #expect(sut.state == .surveyOpened(isPositive: false))
        #expect(sut.selection == false)
        #expect(!didConfirm)

        let confirm = try #require(scheduledConfirmation)
        confirm()

        #expect(sut.state == .confirmed)
        #expect(sut.selection == nil)
        #expect(didConfirm)
    }

    @Test
    func rate_withoutOpeningSurvey_doesNotScheduleConfirmation() {
        var didSchedule = false
        let sut = makeSUT(scheduleConfirmation: { _ in didSchedule = true })

        sut.rate(isPositive: true)

        #expect(sut.state == .rated(isPositive: true))
        #expect(!didSchedule)
    }

    @Test
    func rate_withoutConsent_requestsConfirmationFocus() {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = .denied
        let sut = makeSUT(analyticsService: mockAnalyticsService)
        var focusRequestCount = 0
        let cancellable = sut.confirmationFocusRequests.sink { focusRequestCount += 1 }

        sut.rate(isPositive: true)

        #expect(focusRequestCount == 1)
        cancellable.cancel()
    }

    @Test
    func surveyDismissed_afterConfirmation_requestsConfirmationFocus() {
        let mockNotificationCenter = MockNotificationCenter()
        let sut = makeSUT(
            scheduleConfirmation: { $0() },
            notificationCenter: mockNotificationCenter
        )
        var focusRequestCount = 0
        let cancellable = sut.confirmationFocusRequests.sink { focusRequestCount += 1 }
        sut.rate(isPositive: true)
        sut.openSurvey()
        #expect(sut.state == .confirmed)
        #expect(focusRequestCount == 1)

        mockNotificationCenter.post(name: .qualtricsSurveyDismissed, object: nil)

        #expect(focusRequestCount == 2)
        cancellable.cancel()
    }

    @Test
    func surveyDismissed_beforeConfirmation_doesNotRequestConfirmationFocus() {
        let mockNotificationCenter = MockNotificationCenter()
        let sut = makeSUT(notificationCenter: mockNotificationCenter)
        var focusRequestCount = 0
        let cancellable = sut.confirmationFocusRequests.sink { focusRequestCount += 1 }
        sut.rate(isPositive: true)
        sut.openSurvey()

        mockNotificationCenter.post(name: .qualtricsSurveyDismissed, object: nil)

        #expect(sut.state == .surveyOpened(isPositive: true))
        #expect(focusRequestCount == 0)
        cancellable.cancel()
    }

    private func makeSUT(
        analyticsService: MockAnalyticsService = MockAnalyticsService(),
        accessibilityAnnouncer: MockAccessibilityAnnouncerService = MockAccessibilityAnnouncerService(),
        scheduleConfirmation: @escaping ChatFeedbackViewModel.ConfirmationScheduler = { _ in },
        notificationCenter: NotificationCenter = MockNotificationCenter(),
        onConfirmed: @escaping () -> Void = { }
    ) -> ChatFeedbackViewModel {
        ChatFeedbackViewModel(
            questionId: "questionId",
            analyticsService: analyticsService,
            accessibilityAnnouncer: accessibilityAnnouncer,
            scheduleConfirmation: scheduleConfirmation,
            notificationCenter: notificationCenter,
            onConfirmed: onConfirmed
        )
    }
}
