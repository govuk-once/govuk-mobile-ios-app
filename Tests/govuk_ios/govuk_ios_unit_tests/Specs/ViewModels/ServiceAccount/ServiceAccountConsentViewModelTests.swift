import Testing

@testable import govuk_ios

@Suite
class ServiceAccountConsentViewModelTests {

    @Test
    func init_dvla_createsCorrectTitle() {
        let sut = ServiceAccountConsentViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {},
            cancelAction: {}
        )
        #expect(sut.title == "Add your driver and vehicles account")
    }

    @Test
    func primaryButtonAction_callsCompletionAction() {
        var completionWasCalled = false
        let sut = ServiceAccountConsentViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {
                completionWasCalled = true
            },
            cancelAction: {}
        )
        sut.primaryButtonViewModel.action()
        #expect(completionWasCalled == true)
    }

    @Test
    func primaryButtonAction_tracksNavigationEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ServiceAccountConsentViewModel(
            analyticsService: mockAnalyticsService,
            accountType: .dvla,
            completionAction: {},
            cancelAction: {}
        )
        sut.primaryButtonViewModel.action()
        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Button")
        #expect(event.params?["text"] as? String == "Continue")
        #expect(event.params?["section"] as? String == "continue")
    }

    @Test
    func cancel_callsCancelAction() {
        var cancelActionWasCalled = false
        let sut = ServiceAccountConsentViewModel(
            analyticsService: MockAnalyticsService(),
            accountType: .dvla,
            completionAction: {},
            cancelAction: {
                cancelActionWasCalled = true
            }
        )
        sut.cancel()
        #expect(cancelActionWasCalled == true)
    }

    @Test
    func cancel_tracksNavigationEvent() throws {
        let mockAnalyticsService = MockAnalyticsService()
        let sut = ServiceAccountConsentViewModel(
            analyticsService: mockAnalyticsService,
            accountType: .dvla,
            completionAction: {},
            cancelAction: {}
        )
        sut.cancel()
        let event = try #require(mockAnalyticsService._trackedEvents.first)
        #expect(event.name == "Navigation")
        #expect(event.params?["type"] as? String == "Close")
        #expect(event.params?["text"] as? String == "N/A")
    }
}
