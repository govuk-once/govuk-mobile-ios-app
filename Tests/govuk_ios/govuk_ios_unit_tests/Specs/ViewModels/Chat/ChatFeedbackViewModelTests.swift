import Foundation
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
        let text = isPositive ? "thumbs up" : "thumbs down"
        #expect(event.name == "Function")
        #expect(event.params?["text"] as? String == text)
        #expect(event.params?["type"] as? String == "feedback")
        #expect(event.params?["section"] as? String == "Chat")
        #expect(event.params?["action"] as? String == text)
        #expect(event.params?["question_id"] as? String == "questionId")
        #expect(event.params?["conversation_id"] == nil)
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
        #expect(event.name == "Navigation")
        #expect(
            event.params?["text"] as? String ==
            (isPositive ? "Say what went well" : "Say what went wrong")
        )
        #expect(event.params?["type"] as? String == "feedback")
        #expect(event.params?["section"] as? String == "Chat")
        #expect(event.params?["external"] as? Bool == false)
        #expect(event.params?["language"] as? String == "en")
        #expect(event.params?["question_id"] as? String == "questionId")
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

    @Test
    func openSurvey_withoutConsent_isIgnored() {
        let mockAnalyticsService = MockAnalyticsService()
        mockAnalyticsService._stubbedPermissionState = .denied
        let sut = makeSUT(analyticsService: mockAnalyticsService)

        sut.rate(isPositive: true)
        sut.openSurvey()

        #expect(sut.state == .rated(isPositive: true))
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

    private func makeSUT(
        analyticsService: MockAnalyticsService = MockAnalyticsService(),
        scheduleConfirmation: @escaping ChatFeedbackViewModel.ConfirmationScheduler = { _ in },
        onConfirmed: @escaping () -> Void = { }
    ) -> ChatFeedbackViewModel {
        ChatFeedbackViewModel(
            questionId: "questionId",
            analyticsService: analyticsService,
            scheduleConfirmation: scheduleConfirmation,
            onConfirmed: onConfirmed
        )
    }
}
